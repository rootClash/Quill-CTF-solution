// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import {Script, console} from "@forge-std/Script.sol";

contract TrueXorScript is Script {
    event Deployed(address _addr);
    function run() external {
        vm.startBroadcast();
        address BoolGiverAddr = deployCode("out/TrueXor.sol/BoolGiver.json");
        emit Deployed(BoolGiverAddr);
        vm.stopBroadcast();
    }
}