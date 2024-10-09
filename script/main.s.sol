// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {RootFounders} from "../src/main.sol";

contract RootFoundersScript is Script {
    RootFounders public rootFounders;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        rootFounders = new RootFounders();

        vm.stopBroadcast();
    }
}
