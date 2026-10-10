// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import {console} from "@forge-std/console.sol";

interface IGame {
    function getBallPossesion() external view returns (address);
}

// "el baile de la gambeta" -> The dance of the dribble
// https://www.youtube.com/watch?v=qzxn85zX2aE
// @author https://twitter.com/eugenioclrc
contract Pelusa {
    /// @notice that owner address cannot reterived using cast. because it is a private immutable variable
    address private immutable owner;
    address internal player;
    uint256 public goals = 1;

    constructor() {
        // @question agar encodePacked(a , b) = (b , a)
        // @question can i get the block number of current block hash?
        owner = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(msg.sender, blockhash(block.number))
                    )
                )
            )
        );
    }

    function passTheBall() external {
        // EOA hona chahiye? nope meine contract ke form mei pass kiya
        require(msg.sender.code.length == 0, "Only EOA players"); // crossed
        /// @notice agar address 20 byte ka hua toh impossible hai !
        console.log("address value : ",uint256(uint160(msg.sender))     );
        require(uint256(uint160(msg.sender)) % 100 == 10, "not allowed");
        player = msg.sender;
    }

    function isGoal() public view returns (bool) {
        // expect ball in owners posession
        return IGame(player).getBallPossesion() == owner;
    }

    function shoot() external {
        require(isGoal(), "missed");
        /// @dev use "the hand of god" trick
        (bool success, bytes memory data) = player.delegatecall(
            abi.encodeWithSignature("handOfGod()")
        );
        require(success, "missed");
        /// toh data jo return kr raha hai wo 20061986 (ye ek date of birth)
        require(uint256(bytes32(data)) == 22_06_1986);
    }
}
