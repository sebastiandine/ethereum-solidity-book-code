// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        console2.log("setUp");
        counter = new Counter();
    }

    function testFuzz_Increment(uint256 x) public {
        vm.assume(x < type(uint256).max);
        
        counter.setNumber(x);
        counter.increment();
        assertEq(counter.number(), x+1);
    }

    function testFuzz_Decrement(uint256 x) public {
        vm.assume(x > type(uint256).min);
        
        counter.setNumber(x);
        counter.decrement();
        assertEq(counter.number(), x-1);
    }

    function testFail_Increment() public {
        counter.setNumber(type(uint256).max);
        counter.increment();
    }

    function testFail_Decrement() public {
        counter.setNumber(type(uint256).min);
        counter.decrement();
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
