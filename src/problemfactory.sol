pragma solidity ^0.4.19;

import "./ownable.sol";

contract ProblemFactory is Ownable {

    struct Problem_SAT {
        uint num_vars;
	// 0: not exist; 1: exist, regular; 2: exist, not
	string clauses;
	uint reward;
    }

    event New_SAT_Problem(uint problemId, uint num_vars, uint reward);
    event New_TSP_Problem(uint id, uint num_nodes, uint max_dist, uint reward);

    struct Problem_TSP {
        uint num_nodes;
	uint max_dist;
	uint reward;
	// TODO
    }

    Problem_SAT[] public sat_problems;
    Problem_TSP[] public tsp_problems;

    // number of problems that the owner has issued
    mapping (address => uint) ownerProblemCount; 
    mapping (uint => address) public satToOwner;
    mapping (uint => address) public tspToOwner;

    function createSATProblem(uint num_vars, string clauses, uint reward) public {
        uint id = sat_problems.push(Problem_SAT(num_vars, clauses, reward));
	satToOwner[id] = msg.sender;
	ownerProblemCount[msg.sender]++;
	emit New_SAT_Problem(id, num_vars, reward);
    }

    function createTSPProblem(uint num_nodes, uint max_dist, uint reward) public {
        uint id = tsp_problems.push(Problem_TSP(num_nodes, max_dist, reward));
	tspToOwner[id] = msg.sender;
	ownerProblemCount[msg.sender]++;
	emit New_TSP_Problem(id, num_nodes, max_dist, reward);
    }
}