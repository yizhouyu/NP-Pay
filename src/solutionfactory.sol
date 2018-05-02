pragma solidity ^0.4.19;

import "./problemfactory.sol";

contract SolutionFactory is ProblemFactory {
    
    // deposit that the problem solver needs to pay to the contract when it proposes
    // a solution hash and a solution. 
    // The deposit is returned if the market accepts the solution 
    uint solution_deposit = 100; // TODO change
    // maximum number of solutions that can be proposed to a given problem
    uint max_solutions_to_record = 3;

    struct SATSolutionHash {
       bytes32 hash; // hash of the solution
       uint256 time_proposed;
       address solver; // address of the person who proposed the solution
    }

    struct SATSolution {
       string assignment;
       uint256 time_hash_proposed; // time that the hash of this solution was proposed
       address solver; // address of the person who proposed the solution
    }
    
    // mapping from problemId to solution hash
    mapping (uint => SATSolutionHash[]) public solutionHashes_SAT; 
    
    // mapping from problemId to solution
    mapping (uint => SATSolution[]) public solutions_SAT; 

    event SATSolutionHashProposed(uint problemId, uint hashId, uint256 time_proposed);
    
    event SATSolutionProposed(uint problemId, uint256 time_proposed);
    
    // propose the hash of the solution to the problem at problemId.
    // returns the index of the new SATSolutionHash struct that is created.
    // This index represents how many people have proposed the solution hash before.
    function proposeSATSolutionHash(uint problemId, bytes32 hash) public payable returns (uint) {
        require(msg.value >= solution_deposit);
        // no more than max_solutions_to_record people can propose a solution hash
        require(solutionHashes_SAT[problemId].length < max_solutions_to_record);
        uint hashId = solutionHashes_SAT[problemId].push(SATSolutionHash(hash, now, msg.sender));
        emit SATSolutionHashProposed(problemId, hashId, now);
        return hashId;
    }
    
    // propose the solution to the problem at problemId.
    function proposeSATSolution(uint problemId, uint hashId, string assignment) public payable {
        require(msg.value >= solution_deposit);
        // check that the hash of the solution exists in the array
        require(solutionHashes_SAT[problemId].length >= hashId);
        SATSolutionHash storage sol_hash = solutionHashes_SAT[problemId][hashId];
        // check that the solution matches the hash
        require (keccak256(assignment) == sol_hash.hash);
        // check that the caller of this function is the same person who proposed the hash 
        require(msg.sender == sol_hash.solver);
        // the hashes match, so we can record the solution now
        solutions_SAT[problemId][hashId] = SATSolution(assignment, sol_hash.time_proposed, msg.sender);
        emit SATSolutionProposed(problemId, now);
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