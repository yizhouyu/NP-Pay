pragma solidity ^0.4.19;

import "./solutionfactory.sol";

contract SolutionVerifier is SolutionFactory {
    // 1000 votes for manual trigger, 7500 votes for auto trigger, 24 hrs for auto trigger

    uint vote_deposit = 100; // TODO change
    uint manual_trigger_gas_cost = 100; // TODO change
    uint trigger_reward_div = 10; // divide reward by trigger_reward_div

    // mapping from problemId to mapping from solutionId to addresses of up votes
    mapping (uint => mapping (uint => address[])) upvotes_SAT; 
    mapping (uint => mapping (uint => address[])) downvotes_SAT;
    // whether a solution has received up votes
    mapping (uint => bool) has_upvotes_SAT; 
    mapping (uint => bool) has_downvotes_SAT;

    // if suggest_verify -> trigger verification on chain
    function vote_SAT(uint problemId, uint solutionId, bool decision, bool want_onchain_verify) public payable {
        require(msg.value >= vote_deposit);
	// check time
	if (decision) {
	    // voted yes
	    upvotes_SAT[problemId][solutionId].push(msg.sender);
	} else {
	    downvotes_SAT[problemId][solutionId].push(msg.sender);
	}
	
	if (want_onchain_verify) {
	    trigger_verification(problemId, solutionId);
	}
    }
    
    function trigger_verification(uint problemId, uint solutionId) public {
        // check first that verifier actually has voted
        Problem_SAT memory problem = sat_problems[problemId];
        SATSolution memory solution = solutions_SAT[problemId][solutionId];
        uint num_upvotes = upvotes_SAT[problemId][solutionId].length; // TODO
        uint num_downvotes = downvotes_SAT[problemId][solutionId].length; // TODO
        uint total_votes = num_upvotes + num_downvotes;
        if (!verify_assignment(problem.clauses, solution.assignment)) {
            // proposed solution is indeed incorrect
            uint256 reward_to_caller = vote_deposit;
            reward_to_caller += manual_trigger_gas_cost;
            uint trigger_reward = (num_upvotes*vote_deposit 
                                       - manual_trigger_gas_cost) / trigger_reward_div;
            reward_to_caller += trigger_reward;
            uint normal_reward = (num_upvotes*vote_deposit - trigger_reward) / num_downvotes;
            reward_to_caller += normal_reward;
            uint256 reward_to_no_voters = vote_deposit + normal_reward;
            // transfer ether to the one who triggered verification
            msg.sender.transfer(reward_to_caller);
            // transfer ether to other voters who voted no
            address[] memory addresses_no = downvotes_SAT[problemId][solutionId];
            for (uint i = 0; i<addresses_no.length; i++) {
                addresses_no[i].transfer(reward_to_no_voters);
            }
        } else {
            // proposed solution is actually correct
            // transfer ether to those who voted yes
            address[] memory addresses_yes = upvotes_SAT[problemId][solutionId];
            uint256 reward_to_yes_voters = total_votes * vote_deposit / num_upvotes;
            for (uint j = 0; j<addresses_yes.length; j++) {
                addresses_yes[j].transfer(reward_to_yes_voters);
            }
        }
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