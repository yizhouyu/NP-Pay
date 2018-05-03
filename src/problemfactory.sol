pragma solidity ^0.4.19;

import "./ownable.sol";

contract ProblemFactory is Ownable {

    // cost that the problem issuer needs to pay to the contract
    uint problem_issue_cost = 1000; //TODO change
    // limit on the number of unsolved problems that an address can issue.  
    uint problem_limit = 5;
    
    struct Problem_SAT {
        uint num_vars;
	// clauses: 0: exist, negated; 1: exist, regular; 2: not exist
	string clauses;
	uint reward;
    }

    event New_SAT_Problem(uint problemId, uint num_vars, uint reward);
    
    // stores all problems that have been proposed
    Problem_SAT[] public sat_problems;

    // number of problems that the owner has issued
    mapping (address => uint) ownerProblemCount; 
    // mapping from problem id to its issuer
    mapping (uint => address) public satToOwner;

    // issue an SAT problem to the market. Returns the id of the problem.
    function createSATProblem(uint num_vars, string clauses, uint reward) public payable returns (uint) {
        require(msg.value >= reward + problem_issue_cost);
        require(ownerProblemCount[msg.sender] < problem_limit);
        uint problemId = sat_problems.push(Problem_SAT(num_vars, clauses, reward));
	satToOwner[problemId] = msg.sender;
	ownerProblemCount[msg.sender]++;
	emit New_SAT_Problem(problemId, num_vars, reward);
	return problemId;
    }
}