pragma solidity ^0.4.19;

import "./solutionverifier.sol";

contract BalanceResolver is SolutionVerifier {
    // retrieve money from balance
    function retrieve_reward() public {
        msg.sender.transfer(balance[msg.sender]);
    }
    
}