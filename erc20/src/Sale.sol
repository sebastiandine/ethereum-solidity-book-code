// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { IERC20 } from "./ERC20.sol";

contract Sale {

    address public token;
    address public owner;
    uint256 public ratio;

    constructor(address _token, uint256 _ratio) {
        token = _token;
        ratio = _ratio;
        owner = msg.sender;
    }

    function buy() external payable {
        uint256 tokenAmount = msg.value * ratio;
        require(tokenAmount <= IERC20(token).balanceOf(address(this)),
            "Sale contract does not own enough tokens.");
        IERC20(token).transfer(msg.sender, tokenAmount);
    }

    function withdraw() external {
        payable(owner).transfer(address(this).balance);
    }

}