pragma solidity ^0.4.19;

import "./solutionverifier.sol";

contract BalanceResolver is SolutionVerifier {
    
    // problem solver requests to get the reward correctly solving the problem
    function request_reward(uint problemId, uint solutionId) public {
        Problem_SAT memory problem = sat_problems[problemId];
        SATSolution memory solution = solutions_SAT[problemId][solutionId];
        // TODO check that the solution is proposed the first
        if (solution_is_verified[problemId][solutionId] && solution_is_correct[problemId][solutionId]) {
            balance[solution.solver] += problem.reward;
        }
    }
    
    // retrieve money from balance
    function retrieve_reward() public {
        msg.sender.transfer(balance[msg.sender]);
    }
    
}