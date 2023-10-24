// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20, ERC20} from "../src/ERC20.sol";

contract ERC20Test is Test {
    IERC20 public token;
    address public deployer;

    function setUp() public {
        deployer = address(1);
        vm.prank(deployer);
        token = new ERC20("MyCoolToken", "MCT", 100000000000000000000);
    }

    function test_Tokenomics() public {
        assertEq(token.name(), "MyCoolToken");
        assertEq(token.symbol(), "MCT");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 100000000000000000000);
        assertEq(token.balanceOf(deployer), token.totalSupply());
    }

    function testFuzz_Transfer(address receiver, uint256 value) public {
        vm.assume(value <= token.balanceOf(deployer));

        uint256 senderBalanceBefore = token.balanceOf(deployer);
        uint256 receiverBalanceBefore = token.balanceOf(receiver);

        vm.prank(deployer);
        token.transfer(receiver, value);

        assertEq(token.balanceOf(deployer), senderBalanceBefore - value);
        assertEq(token.balanceOf(receiver), receiverBalanceBefore + value);
    }

    function testFail_TransferFromEmptyBalance(address sender, address receiver) public {
        vm.assume(token.balanceOf(sender) == 0);

        vm.prank(sender);
        token.transfer(receiver, 1);
    }

    function testFail_TransferWithBalanceTooLow(address sender, address receiver, uint256 value) public {
        vm.assume(token.balanceOf(sender) == 0);
        vm.assume(value <= token.balanceOf(deployer));

        vm.prank(deployer);
        token.transfer(sender, value-1);

        vm.prank(sender);
        token.transfer(receiver, value);
    }

    function testFuzz_TransferFrom(address sender, address receiver, uint256 value) public {
        vm.assume(value <= token.balanceOf(deployer));
        vm.assume(value > 0);

        uint256 ownerBalanceBefore = token.balanceOf(deployer);
        uint256 receiverBalanceBefore = token.balanceOf(receiver);

        vm.prank(deployer);
        token.approve(sender, value);
        assertEq(token.allowance(deployer, sender), value);

        vm.prank(sender);
        token.transferFrom(deployer, receiver, value);

        assertEq(token.balanceOf(deployer), ownerBalanceBefore - value);
        assertEq(token.balanceOf(receiver), receiverBalanceBefore + value);
        assertEq(token.allowance(deployer, sender), 0);
    }

    function testFail_TransferFromNoApproval(address sender, address receiver, uint256 value) public {
        vm.assume(value <= token.balanceOf(deployer));
        vm.assume(value > 0);

        vm.prank(sender);
        token.transferFrom(deployer, receiver, value);
    }

    function testFail_TransferFromApprovalTooLow(address sender, address receiver, uint256 value) public {
        vm.assume(value <= token.balanceOf(deployer));
        vm.assume(value > 0);

        vm.prank(deployer);
        token.approve(sender, value);
        assertEq(token.allowance(deployer, sender), value-1);

        vm.prank(sender);
        token.transferFrom(deployer, receiver, value);
    }

    function testFail_TransferFromBalanceTooLow(address sender, address receiver) public {
        
        uint256 ownerBalance = token.balanceOf(deployer);

        vm.prank(deployer);
        token.approve(sender, ownerBalance+1);

        vm.prank(sender);
        token.transferFrom(deployer, receiver, ownerBalance+1);
    }
}
