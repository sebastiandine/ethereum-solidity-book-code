// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {ERC20} from "../src/ERC20.sol";
import {Sale} from "../src/Sale.sol";

contract ERC20Sale is Script {

    function run() public {
        vm.startBroadcast();

        ERC20 token = new ERC20("MyFirstToken", "MFT", 100000000000000000000);
        console2.log("token address: %s", address(token));

        Sale sale = new Sale(address(token), 5);
        console2.log("sale address: %s", address(sale));

        token.transfer(address(sale), 50000000000000000000);
        console2.log("sale balance: %s", token.balanceOf(address(sale)));

        vm.stopBroadcast();
    }
}
