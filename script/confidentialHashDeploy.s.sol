// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import {Script, console} from "@forge-std/Script.sol";

contract ConfidentialHashScript is Script {
    function run() public {
        vm.startBroadcast();
        address confidential = deployCode(
            "out/confidentialHash.sol/Confidential.json"
        );
        console.log("address of contract : ", confidential);
        vm.stopBroadcast();
    }
}
