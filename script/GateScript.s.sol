// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import {Script, console} from "@forge-std/Script.sol";

contract GateScript is Script {
    function run() public {
        vm.startBroadcast();
        address gate_guradian = deployCode("out/Gate.sol/GateGuradian.json");
        address Gate = deployCode("out/Gate.sol/Gate.json");
        vm.stopBroadcast();
        console.log("gate guradian contact address : ", gate_guradian);
        console.log("Gate contract address : ", Gate);
    }
}
