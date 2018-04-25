pragma solidity ^0.4.19;

import "./problemfactory.sol";

contract SolutionFactory is ProblemFactory {

    // TODO change
    uint min_deposit_solve = 100; 
    uint max_solutions_to_accept = 3;

    struct SATSolutionHash {
       uint256 hash;
       uint256 time_proposed;
       address solver; // the person who proposed the solution
    }

    struct SATSolution {
       string assignment;
       address solver; // the person who proposed the solution
    }
    
    // mapping from problemId to solution hash
    mapping (uint => SATSolutionHash[]) public solutions_SATHash; 
    
    // mapping from problemId to solution
    mapping (uint => SATSolution[]) public solutions_SAT; 

    event SATSolutionHashProposed(uint problemId, uint256 time_proposed);
    
    event SATSolutionProposed(uint problemId, uint256 time_proposed);
    
    function proposeSATSolution(uint problemId, uint256 hash) public payable {
        require(msg.value >= min_deposit_solve);
        require(solutions_SATHash[problemId].length < max_solutions_to_accept);
        solutions_SATHash[problemId].push(SATSolutionHash(hash, now, msg.sender));
        emit SATSolutionHashProposed(problemId, now);
    }
}

/*

    struct TSPSolutionHash {
        uint256 hash;
        uint256 time_proposed;
        address solver;
    }

    struct TSPSolution {
       address solver;
    }
    
    mapping (uint => TSPSolutionHash[]) public solutions_TSPHash;
    
    mapping (uint => TSPSolution[]) public solutions_TSP;
    
    event TSPSolutionHashProposed(uint problemId, uint256 time_proposed);
    event TSPSolutionProposed(uint problemId, uint256 time_proposed);
    
    function proposeTSPSolution(uint problemId, uint256 hash) public payable{
        require(msg.value >= min_deposit_solve);
        require(solutions_TSPHash[problemId].length < max_solutions_to_accept);
        solutions_TSPHash[problemId].push(TSPSolutionHash(hash, now, msg.sender));
        emit TSPSolutionHashProposed(problemId, now);
	// TODO
    }
    
*/