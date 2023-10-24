// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {DBlog} from "../src/DBlog.sol";

contract DBlogTest is Test {
    DBlog public blog;

    function setUp() public {
        blog = new DBlog();
    }

    function testFuzz_CreateBlogAndPosts(address user, uint256 block1, uint256 block2) public {
        vm.assume(block1 < block2);
        vm.assume(block2 < type(uint256).max);

        // init a new blog
        vm.prank(user);
        blog.initBlog();

        // validate initial blog metadata
        (uint256 blockFirst, uint256 blockLast, uint256 postCount) 
            = blog.blogMetadata(user);
        assertEq(blockFirst, 0);
        assertEq(blockLast, 0);
        assertEq(postCount, 0);

        // first blog post
        vm.roll(block1);
        vm.recordLogs();
        vm.prank(user);
        blog.post("lorem ipsum dolor sit amet");

        // validate blog post event
        Vm.Log[] memory entries = vm.getRecordedLogs();
        assertEq(entries.length, 1);
        assertEq(entries[0].topics[0], keccak256("BlogPost(address,uint256,string)"));
        assertEq(entries[0].topics[1], bytes32((uint256(uint160(user)))));
        assertEq(entries[0].topics[2], bytes32(uint256(0)));
        assertEq(abi.decode(entries[0].data, (string)), "lorem ipsum dolor sit amet");
        
        // check metadata afterwards first blog post
        (blockFirst, blockLast, postCount) = blog.blogMetadata(user);
        assertEq(blockFirst, block1);
        assertEq(blockLast, block1);
        assertEq(postCount, 1);

        // second blog post & metadata check
        vm.roll(block2);  
        vm.prank(user);
        blog.post("consetetur sadipscing elitr");
        (blockFirst, blockLast, postCount) = blog.blogMetadata(user);
        assertEq(blockFirst, block1);
        assertEq(blockLast, block2);
        assertEq(postCount, 2);
    }

}