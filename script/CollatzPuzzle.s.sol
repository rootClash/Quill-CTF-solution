// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import {Script, console} from "@forge-std/Script.sol";

contract CollatezPuzzleScript is Script {
    function run() public {
        vm.startBroadcast();
        address confidential = deployCode("out/CollatzPuzzle.sol/Collatz.json");
        address anotherDeploy = deployCode("out/CollatzPuzzle.sol/CollatzPuzzle.json");
        vm.stopBroadcast();
        console.log("address 1 : ", confidential);
        console.log("address 2 : " , anotherDeploy);
    }
}
