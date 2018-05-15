pragma solidity ^0.4.19;

import "./solutionfactory.sol";
import "./safemath.sol";

contract SolutionVerifier is SolutionFactory {
    
    using SafeMath for uint256;

    uint vote_deposit = 0.01 ether;
    uint manual_trigger_gas_cost = 0.001 ether; // estimated gas cost to run manual trigger
    // minimum number of votes already collected required in order to manually trigger on-chain verification
    uint min_votes_to_manual_trigger = 1000; 
    uint min_votes_to_auto_trigger = 7500;
    uint min_time_to_auto_trigger = 24 hours;
    uint trigger_reward_div = 10; // divide reward by trigger_reward_div
    
    string server_url = "github.com"; //TODO change to url of server

    // mapping from problemId to [mapping from solutionId to addresses of up votes]
    mapping (uint => mapping (uint => address[])) upvotes_SAT; 
    mapping (uint => mapping (uint => address[])) downvotes_SAT;
    // mapping from problemId to [mapping from solutionId to evidence]
    // evidence provided down-voters about which clause is unsatisfied by the solution assignment
    mapping (uint => mapping (uint => uint[])) evidence_against_solution;
    
    // whether the on-chain verification has been triggered and run on-chain
    mapping (uint => mapping (uint => bool)) solution_is_verified;
    // result of the verification
    mapping (uint => mapping (uint => bool)) solution_is_correct;
    // whether the solver has voted to a specific solution
    mapping (address => mapping (uint => mapping (uint => bool))) has_voted;
    
    // balance of each player
    mapping (address => uint) internal balance;
    
    event Vote_Cast(uint problemId, uint solutionId, bool vote, address voter);
    // [result] is the result of the verification
    event Verification_Performed(uint problemId, uint solutionId, bool result);
    
    // vote on the solution
    // if trigger_verify -> trigger verification on chain
    // need to provide evidence if you want to vote against the solution, and indicate which clause is unsatisfied by the solution assignment
    function vote_SAT(uint problemId, uint solutionId, uint evidence, bool trigger_verify, bool vote_up) public payable {
        // the problem must exist
        require(sat_problems.length > problemId);
        // the solution must exist
        require(solutions_SAT[problemId].length > solutionId);
        // cannot vote after the verification function has been called
        require(!solution_is_verified[problemId][solutionId]);
        require(!has_voted[msg.sender][problemId][solutionId]);
        require(msg.value >= vote_deposit);
        if (trigger_verify) {
            require(!vote_up);
    	    require(can_trigger_manual_verification(problemId, solutionId));
        }
        has_voted[msg.sender][problemId][solutionId] = true;
        if (vote_up) {
	        // vote for the solution
	        upvotes_SAT[problemId][solutionId].push(msg.sender);
	    } else {
	        // vote against the solution
	        downvotes_SAT[problemId][solutionId].push(msg.sender);
	        uint[] storage evidences = evidence_against_solution[problemId][solutionId];
	        // go through evidences to make sure that the evidence has never been proposed before
	        // because the array "evidences" should not contain two duplicate evidences.
	        bool evidence_already_proposed = false;
	        for (uint i = 0; i < evidences.length; i++){
	            if (evidences[i] == evidence) {
	                evidence_already_proposed = true;
	                break;
	            }
	        }
	        if (!evidence_already_proposed) {
	            evidences.push(evidence);
	        }
	    }
	    emit Vote_Cast(problemId, solutionId, vote_up, msg.sender);
	
    	if (trigger_verify) {
    	    trigger_manual_verification(problemId, solutionId, vote_up);
    	} else if (can_trigger_auto_verification(problemId, solutionId)){
    	    trigger_auto_verification(problemId, solutionId);
    	}
    }
    
    /*
        whether conditions for a manual trigger of verification are met
         i.e. if both of the following two conditions are met:
         1. There are voters who voted up and voters who voted down
         2. The total number of votes is greater than min_votes_to_manual_trigger
    */ 
    function can_trigger_manual_verification(uint problemId, uint solutionId) public view returns (bool) {
        uint num_upvotes = upvotes_SAT[problemId][solutionId].length;
        uint num_downvotes = downvotes_SAT[problemId][solutionId].length;
        // there is disagreement among voters, and the total number of voters is over min_votes_to_manual_trigger
        return (num_upvotes>0 && num_downvotes>0) && (num_upvotes + num_downvotes > min_votes_to_manual_trigger);
    }
    
    /*
        whether conditions for a manual trigger of verification are met
         i.e. if either of the following two conditions is met:
         1. Vote condition: the total number of votes is greater than min_votes_to_auto_trigger
         2. Time condiion: min_time_to_auto_trigger has passed since the solution was put forward to be voted on
    */ 
    function can_trigger_auto_verification(uint problemId, uint solutionId) public view returns (bool) {
        uint num_upvotes = upvotes_SAT[problemId][solutionId].length;
        uint num_downvotes = downvotes_SAT[problemId][solutionId].length;
        // require that there is disagreement among voters
        require(num_upvotes>0 && num_downvotes>0);
        bool condition_1 = (num_upvotes.add(num_downvotes) > min_votes_to_auto_trigger); // vote condition
        SATSolution memory solution = solutions_SAT[problemId][solutionId];
        bool condition_2 = (now.sub(solution.time_sol_proposed) > min_time_to_auto_trigger); // time condition
        return (condition_1 || condition_2);
    }
    
    // checks whether the solution to the problem is correct.
    // vote_up is the vote that the caller cast.
    function trigger_manual_verification(uint problemId, uint solutionId, bool vote_up) private {
        address[] memory up_voters = upvotes_SAT[problemId][solutionId];
        address[] memory down_voters = downvotes_SAT[problemId][solutionId];
        uint num_upvotes = up_voters.length;
        uint num_downvotes = down_voters.length;
        uint balance_to_add;
        
        if (!verify_solution(problemId, solutionId)) {
            // proposed solution is incorrect
            solution_is_correct[problemId][solutionId] = false;
            emit Verification_Performed(problemId, solutionId, false);
            
            if (!vote_up) {
                // the caller of the verification is correct.
                // the one who triggered verification gets reward
                // reimburse gas cost
                balance[msg.sender] = balance[msg.sender].add(manual_trigger_gas_cost);
                // reward for triggering verification
                uint trigger_reward = ((num_upvotes.mul(vote_deposit)).sub(manual_trigger_gas_cost)).div(trigger_reward_div);
                balance[msg.sender] = balance[msg.sender].add(trigger_reward);
                uint normal_reward = ((num_upvotes.mul(vote_deposit)).sub(trigger_reward)).div(num_downvotes);
                balance[msg.sender] =  balance[msg.sender].add(normal_reward);
                // the other voters who voted against the proposed solution get reward
                for (uint i = 0; i<down_voters.length; i++) {
                    balance[down_voters[i]] = balance[down_voters[i]].add((vote_deposit.add(normal_reward)));
                }
            } else {
                // the caller of the verification is incorrect
                for (i = 0; i<down_voters.length; i++) {
                    balance_to_add = (((num_upvotes.add(num_downvotes)).mul(vote_deposit)).div(num_downvotes)); 
                    balance[down_voters[i]] = balance[down_voters[i]].add(balance_to_add);
                }
            }
        } else {
            // proposed solution is correct
            solution_is_correct[problemId][solutionId] = true;
            emit Verification_Performed(problemId, solutionId, true);
            if (vote_up) {
                // the caller of the verification is correct
                // the one who triggered verification gets reward
                // reimburse gas cost
                balance[msg.sender] = balance[msg.sender].add(manual_trigger_gas_cost);
                // reward for triggering verification
                trigger_reward = ((num_downvotes.mul(vote_deposit)).sub(manual_trigger_gas_cost)).div(trigger_reward_div);
                balance[msg.sender] = balance[msg.sender].add(trigger_reward);
                normal_reward = ((num_downvotes.mul(vote_deposit)).sub(trigger_reward)).div(num_upvotes);
                balance[msg.sender] = balance[msg.sender].add(normal_reward);
                // the other voters who voted for the proposed solution get reward
                for (i = 0; i<up_voters.length; i++) {
                    balance[up_voters[i]] = balance[up_voters[i]].add(vote_deposit.add(normal_reward));
                }
            } else {
                // the caller of the verification is incorrect
                for (i = 0; i<up_voters.length; i++) {
                    balance_to_add = ((num_upvotes.add(num_downvotes)).mul(vote_deposit)).div(num_upvotes);
                    balance[up_voters[i]] = balance[up_voters[i]].add(balance_to_add);
                }
        }
        } 
        solution_is_verified[problemId][solutionId] = true;
    }
    
    function trigger_auto_verification(uint problemId, uint solutionId) private {
        address[] memory up_voter_addresses = upvotes_SAT[problemId][solutionId];
        address[] memory down_voter_addresses = downvotes_SAT[problemId][solutionId];
        uint num_upvotes = up_voter_addresses.length;
        uint num_downvotes = down_voter_addresses.length;
        uint total_votes = num_upvotes.add(num_downvotes);
        uint balance_to_add;
        
        if (!verify_solution(problemId, solutionId)) {
            // proposed solution is incorrect
            solution_is_correct[problemId][solutionId] = false;
            emit Verification_Performed(problemId, solutionId, false);
            // those who cast down votes get the reward
            for (uint i = 0; i<down_voter_addresses.length; i++) {
                balance_to_add = (total_votes.mul(vote_deposit)).div(num_downvotes);
                balance[down_voter_addresses[i]] = balance[down_voter_addresses[i]].add(balance_to_add);
            }
        } else {
            // proposed solution is correct
            solution_is_correct[problemId][solutionId] = true;
            emit Verification_Performed(problemId, solutionId, true);
            // those who cast up votes get the reward
            for (i = 0; i<up_voter_addresses.length; i++) {
                balance_to_add = (total_votes.mul(vote_deposit)).div(num_upvotes);
                balance[up_voter_addresses[i]] = balance[up_voter_addresses[i]].add(balance_to_add); 
            }
        }
        solution_is_verified[problemId][solutionId] = true;
    }
    
    // TODO
    // Read a clause from the url and verify that the clause is correctly returned from the url
    // clauses: 0: exist, negated; 1: exist, regular; 2: not exist
    function read_clause_from_url(string url, uint clause_no) private pure returns (string) {
        url = "";
        clause_no = 0;
        return "102";
    }
    
    // check whether solutions_SAT[problemId][solutionId] is a valid solution by 
    // checking it against all the evidence proposed by down-voters
    // precondition: valid problemId and solutionId
    function verify_solution(uint problemId, uint solutionId) view private returns (bool) {
        uint[] memory evidences = evidence_against_solution[problemId][solutionId];
        string memory sol = solutions_SAT[problemId][solutionId].assignment;
        for (uint i = 0; i < evidences.length; i++) {
            uint evidence = evidences[i];
            string memory clause = read_clause_from_url(server_url, evidence);
            if (!verify_assignment(clause, sol)) {
                return false;
            }
        }
        return true;
    }
    
    // run verification on-chain. Check whether [assignment] satisfies [clause].
    // clauses: 0: exist, negated; 1: exist, regular; 2: not exist
    // assignment: binary string, 0: F, 1: T
    function verify_assignment(string clause, string assignment) public pure returns (bool) {
        // convert assignment string to array
        bytes memory b_clause = bytes(clause);
        bytes memory b_assignment = bytes(assignment);
        for (uint i = 0; i < b_clause.length; i++) {
            if ((b_clause[i] == '0' && b_assignment[i] == '0')||(b_clause[i] == '1' && b_assignment[i] == '1')) {
                return true;
            }
        }
        return false;
    }
    
    // not used
    // run verification on-chain. Check whether [assignment] satisfies [clauses].
    function verify_assignment_old(string clauses, string assignment) public pure returns (bool) {
        // convert assignment string to array
        bytes memory b_clauses = bytes(clauses);
        bytes memory b_assignment = bytes(assignment);
        uint ptr_assignment = 0; // pointer on characters in assignment
        bool clause_satisfied = false;
        for (uint i = 0; i < b_clauses.length; i++) {
            // clauses: 0: exist, negated; 1: exist, regular; 2: not exist
            // assignment: 0: F, 1: T
            if (b_clauses[i] == '0' && b_assignment[ptr_assignment] == '0') {
                clause_satisfied = true;
            } else if (b_clauses[i] == '1' && b_assignment[ptr_assignment] == '1') {
                clause_satisfied = true;
            }
            ptr_assignment += 1;
            if (ptr_assignment == b_assignment.length) {
                ptr_assignment = 0;
                if (!clause_satisfied) {
                    return false;
                } else {
                    clause_satisfied = false;
                }
            }
        }
        return true;
    }
}