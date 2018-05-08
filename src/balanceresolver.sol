pragma solidity ^0.4.19;

import "./solutionverifier.sol";

contract BalanceResolver is SolutionVerifier {
    
    // time window during which the network can vote on the solution
    uint cooldown_period = 1 minutes;
    
    // problem solver requests to get the reward after correctly solving the problem
    function request_reward(uint problemId, uint solutionId) public {
        Problem_SAT memory problem = sat_problems[problemId];
        SATSolution memory solution = solutions_SAT[problemId][solutionId];
        // caller must be the one who proposed the solution
        require(solution.solver == msg.sender);
        // cooldown period must have passed
        require(solution.time_sol_proposed + cooldown_period < now);
        // TODO check that the solution is proposed the first
        bool verified_and_correct = solution_is_verified[problemId][solutionId] && solution_is_correct[problemId][solutionId];
        bool no_dissent = (downvotes_SAT[problemId][solutionId].length == 0);
        if (verified_and_correct || no_dissent) {
            balance[solution.solver] += problem.reward;
            problem.solved = true;
        }
        // return deposit to voters
    }
    
    // retrieve money from balance
    function retrieve_reward() public {
        uint amt = balance[msg.sender];
        balance[msg.sender] = 0;
        msg.sender.transfer(amt);
    }
    
}