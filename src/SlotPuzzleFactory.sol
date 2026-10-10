// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";
import {SlotPuzzle} from "./SlotPuzzle.sol";
import {EnumerableSet} from "lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import "./ISlotPuzzleFactory.sol";

contract SlotPuzzleFactory is ReentrancyGuard{
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeTransferLib for address;

    EnumerableSet.AddressSet deployedAddress;

    constructor() payable {
        require(msg.value == 3 ether);
    }

    function deploy(Parameters calldata params) external nonReentrant {
        SlotPuzzle newContract = new SlotPuzzle();

        // @audit unchecked return value from add()
        deployedAddress.add(address(newContract)); 
        // @audit unchecked return value from ascertionSlot  
        newContract.ascertainSlot(params); 
    }

    function payout(address wallet,uint256 amount) external {
        require(deployedAddress.contains(msg.sender));
        require(amount == 1 ether);
        wallet.safeTransferETH(amount);
    }   
}