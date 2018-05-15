pragma solidity ^0.4.19;

import "./ownable.sol";
import "./safemath.sol";

contract ProblemFactory is Ownable {
    
    using SafeMath for uint256;

    // cost that the problem issuer needs to pay to the contract
    uint problem_issue_cost = 0.01 ether;
    // limit on the number of unsolved problems that an address can issue.  
    uint problem_limit = 5;
    
    struct Problem_SAT {
        address issuer;
        string url; // url to the problem stored on server
        bytes32 problem_hash; // hash of the problem
        uint num_vars;
        uint num_clauses;
        uint reward;
    	// whether or not the problem has already been solved
    	bool solved; 
    }

    event New_SAT_Problem(uint problemId, uint num_vars, uint num_clauses, uint reward);
    
    // stores all problems that have been proposed
    Problem_SAT[] internal sat_problems;
    
    mapping (uint => address) public satToOwner;
    // number of problems that the owner has issued
    mapping (address => uint) ownerProblemCount; 

    // issue an SAT problem to the market. Returns the id of the problem.
    function createSATProblem(string url, bytes32 problem_hash, uint num_vars, uint num_clauses, uint reward) public payable returns (uint) {
        require(msg.value >= reward.add(problem_issue_cost));
        require(ownerProblemCount[msg.sender] < problem_limit);
        // unique problemId for each problem
        uint problemId = sat_problems.push(Problem_SAT(msg.sender, url, problem_hash, num_vars, num_clauses, reward, false));
    	satToOwner[problemId] = msg.sender;
    	ownerProblemCount[msg.sender]++;
    	emit New_SAT_Problem(problemId, num_vars, num_clauses, reward);
    	return problemId;
    }
    
    // basic information about the problem
    function get_SATProblem_info(uint problemId) view public 
        returns (address issuer, string url, bytes32 problem_hash, uint num_vars, uint num_clauses, uint reward, bool solved) {
        require(problemId < sat_problems.length);
        Problem_SAT memory P = sat_problems[problemId];
        return (P.issuer, P.url, P.problem_hash, P.num_vars, P.num_clauses, P.reward, P.solved);
    }
}