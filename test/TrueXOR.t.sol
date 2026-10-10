// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "@forge-std/Test.sol";
import {BoolGiver} from "../src/TrueXor.sol";
import {TrueXOR} from "../src/TrueXor.sol";

contract TrueXORTest is Test {
    BoolGiver boolGiver;
    TrueXOR trueXor;
    function setUp() public {
        boolGiver = new BoolGiver();
        trueXor = new TrueXOR();
    }

    function test_callMe() public {
        vm.startPrank(msg.sender);
        bool value = trueXor.callMe{gas : 10000}(address(boolGiver));
        vm.stopPrank();
        assert(value == true);
    }
}