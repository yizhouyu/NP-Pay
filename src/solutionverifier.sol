pragma solidity ^0.4.19;

import "./solutionfactory.sol";

contract SolutionVerifier is SolutionFactory {
    // 1000 votes for manual trigger, 7500 votes for auto trigger, 24 hrs for auto trigger

    uint vote_deposit = 100; // TODO change
    uint manual_trigger_gas_cost = 100; // TODO change
    // minimum number of votes already collected in order to trigger on-chain verification
    uint min_votes_to_manual_trigger = 1000; 
    uint min_votes_to_auto_trigger = 7500;
    uint min_time_to_auto_trigger = 1 days;
    uint trigger_reward_div = 10; // divide reward by trigger_reward_div

    // mapping from problemId to [mapping from solutionId to addresses of up votes]
    mapping (uint => mapping (uint => address[])) upvotes_SAT; 
    mapping (uint => mapping (uint => address[])) downvotes_SAT;
    
    // whether the on-chain verification has been triggered and run on-chain
    mapping (uint => mapping (uint => bool)) solution_is_verified;
    
    // balance of each player
    mapping (address => uint) balance;
    
    event Vote_Cast(uint problemId, uint solutionId, bool vote);
    // [result] is the result of the verification
    event Verification_Performed(uint problemId, uint solutionId, bool result);

    // if trigger_verify -> trigger verification on chain
    function vote_SAT(uint problemId, uint solutionId, bool vote_up, bool trigger_verify) public payable {
        // cannot vote after the verification function has been called
        require(!solution_is_verified[problemId][solutionId]);
        require(msg.value >= vote_deposit);
	if (vote_up) {
	    // vote for the solution
	    upvotes_SAT[problemId][solutionId].push(msg.sender);
	} else {
	    // vote against the solution
	    downvotes_SAT[problemId][solutionId].push(msg.sender);
	}
	emit Vote_Cast(problemId, solutionId, vote_up);
	
	if (trigger_verify) {
	    require(can_trigger_manual_verification(problemId, solutionId));
	    trigger_manual_verification(problemId, solutionId, vote_up);
	} else if (can_trigger_auto_verification(problemId, solutionId)){
	    trigger_auto_verification(problemId, solutionId);
	}
    }
    
    // whether conditions for a manual trigger of verification are met
    function can_trigger_manual_verification(uint problemId, uint solutionId) public view returns (bool) {
        uint num_upvotes = upvotes_SAT[problemId][solutionId].length;
        uint num_downvotes = downvotes_SAT[problemId][solutionId].length;
        // require that there is disagreement among voters
        bool condition_1 = num_upvotes>0 && num_downvotes>0;
        uint total_votes = num_upvotes + num_downvotes;
        bool condition_2 = total_votes > min_votes_to_manual_trigger;
        return (condition_1 && condition_2);
    }
    
    function can_trigger_auto_verification(uint problemId, uint solutionId) public view returns (bool) {
        SATSolution memory solution = solutions_SAT[problemId][solutionId];
        uint num_upvotes = upvotes_SAT[problemId][solutionId].length;
        uint num_downvotes = downvotes_SAT[problemId][solutionId].length;
        uint total_votes = num_upvotes + num_downvotes;
        bool condition_1 = (total_votes > min_time_to_auto_trigger); // vote condition
        bool condition_2 = (now - solution.time_sol_proposed > 1 days); // time condition
        return (condition_1 || condition_2);
    }
    
    // checks whether the solution to the problem is correct.
    // vote_up is the vote that the caller cast.
    function trigger_manual_verification(uint problemId, uint solutionId, bool vote_up) private {
        address[] memory up_voter_addresses = upvotes_SAT[problemId][solutionId];
        address[] memory down_voter_addresses = downvotes_SAT[problemId][solutionId];
        uint num_upvotes = up_voter_addresses.length;
        uint num_downvotes = down_voter_addresses.length;
        uint total_votes = num_upvotes + num_downvotes;
        
        Problem_SAT memory problem = sat_problems[problemId];
        SATSolution memory solution = solutions_SAT[problemId][solutionId];
        
        if (!verify_assignment(problem.clauses, solution.assignment)) {
            // proposed solution is incorrect
            emit Verification_Performed(problemId, solutionId, false);
            
            if (!vote_up) {
                // the caller of the verification is correct.
                // the one who triggered verification gets reward
                balance[msg.sender] += vote_deposit;
                // reimburse gas cost
                balance[msg.sender] += manual_trigger_gas_cost;
                // reward for triggering verification
                uint trigger_reward = (num_upvotes*vote_deposit - manual_trigger_gas_cost) / trigger_reward_div;
                balance[msg.sender] += trigger_reward;
                uint normal_reward = (num_upvotes*vote_deposit - trigger_reward) / num_downvotes;
                balance[msg.sender] += normal_reward;
                // the other voters who voted for the correct result get reward
                for (uint i = 0; i<down_voter_addresses.length; i++) {
                    balance[down_voter_addresses[i]] += (vote_deposit + normal_reward);
                }
            } else {
                // the caller of the verification is incorrect
                for (i = 0; i<down_voter_addresses.length; i++) {
                    balance[down_voter_addresses[i]] += (total_votes * vote_deposit / num_upvotes);
                }
            }
        } else {
            // proposed solution is correct
            emit Verification_Performed(problemId, solutionId, true);
            if (vote_up) {
                // the caller of the verification is correct
                // TODO
            } else {
                // the caller of the verification is incorrect
                for (i = 0; i<up_voter_addresses.length; i++) {
                    balance[up_voter_addresses[i]] += (total_votes * vote_deposit / num_upvotes);
                }
        }
        } 
    }
    
    function trigger_auto_verification(uint problemId, uint solutionId) private {
        // TODO
    }
    
    // run verification on-chain. Check whether [assignment] satisfies [clauses].
    function verify_assignment(string clauses, string assignment) public pure returns (bool) {
        // convert assignment string to array
        bytes memory b_clauses = bytes(clauses);
        bytes memory b_assignment = bytes(assignment);
        uint ptr_assignment = 0; // pointer on characters in assignment
        for (uint i = 0; i < b_clauses.length; i++) {
            // clauses: 0: exist, negated; 1: exist, regular; 2: not exist
            // assignment: 0: F, 1: T
            if (b_clauses[i] == '0' && b_assignment[ptr_assignment] != '0') {
                return false;
            }
            if (b_clauses[i] == '1' && b_assignment[ptr_assignment] != '1') {
                return false;
            }
            ptr_assignment += 1;
            if (ptr_assignment == b_assignment.length) {
                ptr_assignment = 0;
            }
        }
        return true;
    }
}