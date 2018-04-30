pragma solidity ^0.4.19;

import "./solutionfactory.sol";

contract SolutionVerifier is SolutionFactory {
    // 1000 votes for manual trigger, 7500 votes for auto trigger, 24 hrs for auto trigger

    uint min_deposit_verify = 100; // TODO change

    mapping (uint => address[]) yes_votes_SAT; // mapping from problemId to addresses of yes votes
    mapping (uint => address[]) no_votes_SAT;
    mapping (uint => bool) has_yes_votes_SAT; // whether a problem has received yes votes
    mapping (uint => bool) has_no_votes_SAT;

    function vote_SAT(uint problem_id, bool decision) public payable {
        require(msg.value >= min_deposit_verify);
	// check time
	if (decision) {
	    // voted yes
	    yes_votes_SAT[problem_id].push(msg.sender);
	} else {
	    no_votes_SAT[problem_id].push(msg.sender);
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
            if (b_clauses[i] == 0 && b_assignment[ptr_assignment] != 0) {
                return false;
            }
            if (b_clauses[i] == 1 && b_assignment[ptr_assignment] != 1) {
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