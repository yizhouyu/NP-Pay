pragma solidity ^0.4.19;

import "./ownable.sol";

contract ProblemFactory is Ownable {

    // cost that the problem issuer needs to pay to the contract
    uint problem_issue_cost = 100;
    
    struct Problem_SAT {
        uint num_vars;
	// 0: not exist; 1: exist, regular; 2: exist, negated
	string clauses;
	uint reward;
    }

    event New_SAT_Problem(uint problemId, uint num_vars, uint reward);
    
    Problem_SAT[] public sat_problems;

    // number of problems that the owner has issued
    mapping (address => uint) ownerProblemCount; 
    // mapping from problem id to its issuer
    mapping (uint => address) public satToOwner;

    function createSATProblem(uint num_vars, string clauses, uint reward) public payable {
        require(msg.value >= reward + problem_issue_cost);
        uint id = sat_problems.push(Problem_SAT(num_vars, clauses, reward));
	satToOwner[id] = msg.sender;
	ownerProblemCount[msg.sender]++;
	emit New_SAT_Problem(id, num_vars, reward);
    }
}

/*
event New_TSP_Problem(uint id, uint num_nodes, uint max_dist, uint reward);

struct Problem_TSP {
        uint num_nodes;
	uint max_dist;
	uint reward;
	// TODO
}

Problem_TSP[] public tsp_problems;

mapping (uint => address) public tspToOwner;

function createTSPProblem(uint num_nodes, uint max_dist, uint reward) public {
        uint id = tsp_problems.push(Problem_TSP(num_nodes, max_dist, reward));
	tspToOwner[id] = msg.sender;
	ownerProblemCount[msg.sender]++;
	emit New_TSP_Problem(id, num_nodes, max_dist, reward);
}
*/