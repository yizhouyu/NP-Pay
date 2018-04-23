pragma solidity ^0.4.19;

import "./problemfactory.sol";

contract ProblemSolver is ProblemFactory {

    uint min_deposit_solve = 100; // TODO change

    // mapping from problemId to solution
    mapping (uint => SATSolution) public solutions_SAT; 
    mapping (uint => TSPSolution) public solutions_TSP;

    struct SATSolution {
       string assignment;
       uint32 time_proposed;
       address solver; // the person who proposed the solution
    }

    struct TSPSolution {
       uint32 time_proposed;
       address solver;
    }

    event SATSolutionProposed(uint problemId, uint32 time_proposed);
    event TSPSolutionProposed(uint problemId, uint32 time_proposed);
    
    function proposeSATSolution(uint problemId, string assignment) public {
        require(msg.value >= min_deposit_solve);
	solutions_SAT[problemId] = SATSolution(assignment, now, msg.sender);
	SATSolutionProposed(problemId, now);
    }

    function proposeTSPSolution(uint problemId) public {
        require(msg.value >= min_deposit_solve);
	solutions_TSP[problemId] = TSPSolution(now, msg.sender);
	TSPSolutionProposed(problemId, now);
	// TODO
    }
}