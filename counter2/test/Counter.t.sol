// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;
    address public owner;

    function setUp() public {
        owner = address(0x01);
        vm.prank(owner);
        counter = new Counter();
    }

    function test_OwnerSetUp() public {
        assertEq(counter.owner(), owner);
    }

    function testFuzz_OwnerGuard(address user) public {
        vm.assume(user != owner);

        vm.expectRevert(bytes("Only allowed for contract owner"));
        vm.prank(user);
        counter.setNumber(user, 42);

        vm.prank(owner);
        counter.setNumber(user, 42);
        assertEq(counter.userToNumber(user), 42);
    }

    function testFuzz_Increment(address user, uint256 number) public {
        vm.assume(number < type(uint256).max);
        vm.prank(owner);
        counter.setNumber(user, number);

        vm.prank(user);
        counter.increment();
        assertEq(counter.userToNumber(user), number+1);
    }

    function testFuzz_Decrement(address user, uint256 number) public {
        vm.assume(number > type(uint256).min);
        vm.prank(owner);
        counter.setNumber(user, number);

        vm.prank(user);
        counter.decrement();
        assertEq(counter.userToNumber(user), number-1);
    }

    function testFail_Increment(address user) public {
        vm.prank(owner);
        counter.setNumber(user, type(uint256).max);

        vm.prank(user);
        counter.increment();
    }

    function test_FailIncrement(address user) public {
        vm.prank(owner);
        counter.setNumber(user, type(uint256).max);

        vm.expectRevert(bytes("Type maximum reached. Number cannot be increased any further."));
        vm.prank(user);
        counter.increment();
    }

    function testFail_Decrement(address user) public {
        vm.prank(owner);
        counter.setNumber(user, type(uint256).min);

        vm.prank(user);
        counter.decrement();
    }
}