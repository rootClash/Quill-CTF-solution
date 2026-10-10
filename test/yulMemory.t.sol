// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "@forge-std/Test.sol";

contract MeoryTest is Test {
    function setUp() public {}

    function test_memoery() external view {
        bytes32 wordFreeMemory;
        string memory data = "hello";
        // assembly {
        //    let free_memory := mload(0x40)
        //    // us free pointer memory pr 32
        //    mstore(free_memory , 32)
        //    //  0x80 + 0x20 = new free memory
        //    free_memory := add(free_memory , 0x20)
        //    // update the 0x40 = new free memory pointer
        //    mstore(0x40, free_memory)
        //    // new free memory pointer put the data(length)
        //    mstore(free_memory , mload(data))
        //    // free memory : new free memoey + 0x20 ->
        //    mstore(add(free_memory , 0x20) , mload(add(data , 0x20)))
        //    wordFreeMemory := mload(add(free_memory, 0x20))
        // }

        assembly {
            let ptr := mload(0x40)

            mstore(ptr, 111)
            mstore(ptr, 222)
        }
        console.log("word free memory logged : ");
        console.logBytes32(wordFreeMemory);
    }

    function test_pointer2() external view {
        bytes32 ptr1;
        bytes32 ptr2;
        bytes32 ptr3;

        assembly {
            let ptr := mload(0x40)

            ptr1 := ptr
            mstore(ptr, 100)

            ptr := add(ptr, 0x20)
            ptr2 := ptr
            mstore(ptr, 200)

            ptr := add(ptr, 0x20)
            ptr3 := ptr
        }

        console.log("ptr1:");
        console.logBytes32(ptr1);

        console.log("ptr2:");
        console.logBytes32(ptr2);

        console.log("ptr3:");
        console.logBytes32(ptr3);
    }
}
