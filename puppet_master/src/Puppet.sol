// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console2.sol";

interface IPuppet {
    function action() external;
    function actionCounter() external view returns (uint256);
}

contract Puppet is IPuppet {

    uint256 public actionCounter;

    function action() external {
        console2.log("msg.sender: %s", msg.sender);
        console2.log("tx.origin: %s", tx.origin);
        actionCounter++;
    }

    function resetCounter() external {
        actionCounter = 0;
    }
}
