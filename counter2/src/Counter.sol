// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Counter {
    mapping(address=>uint256) public userToNumber;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only allowed for contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setNumber(address user, uint256 newNumber) external onlyOwner {
        userToNumber[user] = newNumber;
    }

    function increment() external {
        require(userToNumber[msg.sender] < type(uint256).max, 
            "Type maximum reached. Number cannot be increased any further.");
        userToNumber[msg.sender]++;
    }

    function decrement() external {
        require( userToNumber[msg.sender] > type(uint256).min, 
            "Type minimum reached. Number cannot be decreased any further.");
        userToNumber[msg.sender]--;
    }
}
