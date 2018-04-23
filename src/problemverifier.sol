pragma solidity ^0.4.19;

import "./problemsolver.sol";

contract ProblemVerifier is ProblemSolver {
    // 1000 votes for manual trigger, 7500 votes for auto trigger, 24 hrs for auto trigger

    uint min_deposit_verify = 100; // TODO change

    mapping (uint => address[]) yes_votes_SAT; // mapping from problemId to number of yes votes
    mapping (uint => address[]) no_votes_SAT;

    function vote_SAT(uint problem_id, bool decision) {
        require(msg.value >= min_deposit_verify);
    }
}