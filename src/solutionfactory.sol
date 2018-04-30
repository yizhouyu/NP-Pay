pragma solidity ^0.4.19;

import "./problemfactory.sol";

contract SolutionFactory is ProblemFactory {
    
    // cost that the problem solver needs to pay to the contract
    uint min_deposit_solve = 100; // TODO change
    uint max_solutions_to_accept = 3;

    struct SATSolutionHash {
       bytes32 hash;
       uint256 time_proposed;
       address addr_solver; // address of the person who proposed the solution
    }

    struct SATSolution {
       string assignment;
       uint256 time_hash_proposed; // time that the hash was proposed
       address addr_solver; // address of the person who proposed the solution
    }
    
    // mapping from problemId to solution hash
    mapping (uint => SATSolutionHash[]) public solutionHashes_SAT; 
    
    // mapping from problemId to solution
    mapping (uint => SATSolution[]) public solutions_SAT; 

    event SATSolutionHashProposed(uint problemId, uint256 time_proposed);
    
    event SATSolutionProposed(uint problemId, uint256 time_proposed);
    
    function proposeSATSolutionHash(uint problemId, bytes32 hash) public payable {
        require(msg.value >= min_deposit_solve);
        // no more than max_solutions_to_accept people should have proposed a solution hash
        require(solutionHashes_SAT[problemId].length < max_solutions_to_accept);
        solutionHashes_SAT[problemId].push(SATSolutionHash(hash, now, msg.sender));
        emit SATSolutionHashProposed(problemId, now);
    }
    
    function proposeSATSolution(uint problemId, string assignment) public payable {
        require(msg.value >= min_deposit_solve);
        for (uint i = 0; i < solutionHashes_SAT[problemId].length; i++) {
            SATSolutionHash storage sol_hash = solutionHashes_SAT[problemId][i];
            if(keccak256(assignment) == sol_hash.hash && sol_hash.addr_solver == msg.sender) {
                // the hashes match. can record solution now
                solutions_SAT[problemId].push(SATSolution(assignment, sol_hash.time_proposed, msg.sender));
                emit SATSolutionHashProposed(problemId, now);
            }
        }
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
    
    mapping (uint => TSPSolutionHash[]) public solutionsHashes_TSP;
    
    mapping (uint => TSPSolution[]) public solutions_TSP;
    
    event TSPSolutionHashProposed(uint problemId, uint256 time_proposed);
    event TSPSolutionProposed(uint problemId, uint256 time_proposed);
    
    function proposeTSPSolution(uint problemId, uint256 hash) public payable{
        require(msg.value >= min_deposit_solve);
        require(solutionsHashes_TSP[problemId].length < max_solutions_to_accept);
        solutionsHashes_TSP[problemId].push(TSPSolutionHash(hash, now, msg.sender));
        emit TSPSolutionHashProposed(problemId, now);
	// TODO
    }
    
*/