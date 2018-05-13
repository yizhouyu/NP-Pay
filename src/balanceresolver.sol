pragma solidity ^0.4.19;

import "./solutionverifier.sol";

contract BalanceResolver is SolutionVerifier {
    
    // minimum time window during which the network can vote on the solution
    uint cooldown_period = 1 minutes;
    
    // final solution to problems
    mapping (uint => string) final_solution;
    
    // returns the money that the address is entitled to
    function get_balance() public view returns (uint){
        return balance[msg.sender];
    }
    
    // problem solver requests to get the reward after correctly solving the problem
    function request_reward(uint problemId, uint solutionId) public {
        // the problem must exist
        require(sat_problems.length > problemId);
        // the solution must exist
        require(solutions_SAT[problemId].length > solutionId);
        Problem_SAT memory problem = sat_problems[problemId];
        SATSolution memory solution = solutions_SAT[problemId][solutionId];
        // caller must be the one who proposed the solution
        require(solution.solver == msg.sender);
        // cooldown period must have passed
        require(solution.time_sol_proposed + cooldown_period < now);
        // reward cannot have been already given to another solver
        require (!problem.solved);
        bool verified_and_correct = solution_is_verified[problemId][solutionId] && solution_is_correct[problemId][solutionId];
        bool has_up_votes = (upvotes_SAT[problemId][solutionId].length > 0);
        bool no_down_vote = (downvotes_SAT[problemId][solutionId].length == 0);
        if (verified_and_correct || (has_up_votes && no_down_vote)) {
            balance[solution.solver] += problem.reward;
            problem.solved = true;
            final_solution[problemId] = solution.assignment;
            if (no_down_vote) {
                // return vote deposit to up-voters
                address[] memory up_voters = upvotes_SAT[problemId][solutionId];
                for (uint i = 0; i<up_voters.length; i++) {
                    balance[up_voters[i]] += vote_deposit;
                }
            }
        }
        // return deposit to voters of other solutions of the same problem
        // no matter what they voted, as long as no veriication has been 
        // previously triggered on the solution
        for (uint s = 0; i<solutions_SAT[problemId].length; i++) {
            if (s == solutionId || solution_is_verified[problemId][s]) {
                continue;
            } else {
                up_voters = upvotes_SAT[problemId][s];
                for (i = 0; i < up_voters.length; i++) {
                    balance[up_voters[i]] += vote_deposit;
                }
                address[] memory down_voters = downvotes_SAT[problemId][s];
                for (i = 0; i < down_voters.length; i++) {
                    balance[down_voters[i]] += vote_deposit;
                }
            }
        }
    }
    
    // returns the solution of the problem
    function get_solution(uint problemId) public view returns (string){
        // the problem must exist
        require(sat_problems.length > problemId);
        // problem must have been solved
        require(sat_problems[problemId].solved);
        return final_solution[problemId];
    }
    
    // retrieve money from balance
    function retrieve_reward() public {
        uint amt = balance[msg.sender];
        balance[msg.sender] = 0;
        msg.sender.transfer(amt);
    }
}