pragma solidity ^0.4.19;

import "./solutionfactory.sol";

contract SolutionVerifier is SolutionFactory {
    // 1000 votes for manual trigger, 7500 votes for auto trigger, 24 hrs for auto trigger

    uint min_deposit_verify = 100; // TODO change
    uint manual_trigger_gas_cost = 100; // TODO change
    uint manual_trigger_reward = 200; // TODO change
    uint trigger_reward_div = 10; // divide reward by trigger_reward_div

    mapping (uint => address[]) yes_votes_SAT; // mapping from problemId to addresses of yes votes
    mapping (uint => address[]) no_votes_SAT;
    mapping (uint => bool) has_yes_votes_SAT; // whether a problem has received yes votes
    mapping (uint => bool) has_no_votes_SAT;

    // if suggest_verify -> trigger verification on chain
    function vote_SAT(uint problem_id, bool decision, bool suggest_verify) public payable {
        require(msg.value >= min_deposit_verify);
	// check time
	if (decision) {
	    // voted yes
	    yes_votes_SAT[problem_id].push(msg.sender);
	} else {
	    no_votes_SAT[problem_id].push(msg.sender);
	}
	
	if (suggest_verify) {
	    trigger_verification(problem_id);
	}
    }
    
    function trigger_verification(uint problem_id) public {
        // check first that verifier actually has voted
        Problem_SAT memory problem = sat_problems[problem_id];
        SATSolution memory solution = solutions_SAT[problem_id][0]; // TODO change
        bool is_valid_solution = verify_assignment(problem.clauses, solution.assignment);
        uint num_yes_votes = 70; // TODO
        uint num_no_votes = 30; // TODO
        uint total_votes = num_yes_votes + num_no_votes;
        if (!is_valid_solution) {
            // proposed solution is indeed incorrect
            uint256 reward_to_caller = min_deposit_verify;
            reward_to_caller += manual_trigger_gas_cost;
            uint trigger_reward = (total_votes-num_no_votes) / trigger_reward_div;
            reward_to_caller += trigger_reward;
            uint normal_reward = (total_votes - trigger_reward) / num_no_votes;
            uint256 reward_to_no_voters = min_deposit_verify + normal_reward;
            // transfer ether to the one who triggered verification
            msg.sender.transfer(reward_to_caller);
            // transfer ether to other voters who voted no
            address[] memory addresses_no = no_votes_SAT[problem_id];
            for (uint i = 0; i<addresses_no.length; i++) {
                addresses_no[i].transfer(reward_to_no_voters);
            }
        } else {
            // proposed solution is actually correct
            // transfer ether to those who voted yes
            address[] memory addresses_yes = yes_votes_SAT[problem_id];
            uint256 reward_to_yes_voters = total_votes * min_deposit_verify / num_yes_votes;
            for (uint j = 0; j<addresses_yes.length; j++) {
                addresses_yes[j].transfer(reward_to_yes_voters);
            }
        }
    }
    
    // run verification on-chain
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