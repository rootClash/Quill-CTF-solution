// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {console} from "forge-std/console.sol";

contract PseudoRandom {
    error WrongSig();

    address public owner;

    constructor() {
        bytes32[3] memory input;
        input[0] = bytes32(uint256(1));
        input[1] = bytes32(uint256(2));

        bytes32 scalar;
        assembly {
            scalar := sub(mul(timestamp(), number()), chainid())
        }
        input[2] = scalar;
        console.log("bytes32 data");
        console.logBytes32(scalar);
        assembly {
            // call(gas , addr, 00, input, )
            let success := call(gas(), 0x07, 0x00, input, 0x60, 0x00, 0x40)
            if iszero(success) {
                revert(0x00, 0x00)
            }

            let slot := xor(mload(0x00), mload(0x20))
            
            // sstor(slot , value)
            sstore(add(chainid(), origin()), slot)

            // shl(kitna shift , value)
            let sig := shl(
                // 224
                0xe0,
                or(
                    and(scalar, 0xff000000),
                    or(
                        // 0xff0000 = 4278190080
                        and(shr(xor(origin(), caller()), slot), 0xff0000),
                        or(
                            and(
                                shr(
                                    // 15 , 32 byte
                                    mod(xor(chainid(), origin()), 0x0f),
                                    mload(0x20)
                                ),
                                0xff00
                            ),
                            // shr( (mode % 10) , 32) => add(x , 255) 
                            and(shr(mod(number(), 0x0a), mload(0x20)), 0xff)
                        )
                    )
                )
            )
            sstore(slot, sig)
        }
    }

    fallback() external {
        if (msg.sig == 0x3bc5de30) {
            assembly {
                mstore(0x00, sload(calldataload(0x04)))
                return(0x00, 0x20)
            }
        } else {
            bytes4 sig;

            assembly {
                sig := sload(sload(add(chainid(), caller())))
            }
            console.log("sig value : ");
            console.logBytes32(sig);
            if (msg.sig != sig) {
                revert WrongSig();
            }
            console.log("passed");
            assembly {
                sstore(owner.slot, calldataload(0x24))
            }
        }
    }
}