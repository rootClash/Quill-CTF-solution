// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "@forge-std/Test.sol";
import {Gate,GateGuradian} from "../src/Gate.sol";


contract AttackerContract {
    Gate private gate;
    constructor(Gate _gate) {
        gate = _gate;
    }

    function attackSetup(address _guardian) public {
        gate.open(_guardian);
    }

}   
contract GateTest is Test {
    Gate private gate;
    GateGuradian private guradian;
    address private attacker;
    function setUp() external {
        vm.createSelectFork("http://127.0.0.1:8545");
        guradian = new GateGuradian();
        gate = new Gate();
        
        vm.label(address(gate), "Gate contract Address");
        vm.label(address(guradian) , "Guardian contract Address");
        attacker = makeAddr("attacker");
    }


    function test_PassOpen() public {
        address createdAddress = guradian.deploy();
        vm.label(createdAddress, "hidden contract address");
        vm.startPrank(attacker);
        AttackerContract attackerContract = new AttackerContract(gate);
        attackerContract.attackSetup(createdAddress);
        vm.stopPrank();
    }
}