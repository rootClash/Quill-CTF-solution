pragma solidity ^0.8.17;
import {console} from "forge-std/console.sol";

interface IGuardian {
    function f00000000_bvvvdlt() external view returns (address);

    function f00000001_grffjzz() external view returns (address);
}

contract GateGuradian {
    event Deployed(address indexed);
    function deploy() external returns (address) {
        bytes
            memory bytecode = hex"6020600c60003960206000f360003560e01c8015601757600114601257fe5b326019565b335b5f5260205ff3";
        address addr;

        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(addr != address(0), "CREATE failed");
        emit Deployed(addr);
        return addr;
    }
}

contract Gate {
    bool public opened;

    function open(address guardian) external {
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(guardian)
        }
        require(codeSize < 33, "bad code size");
        console.log("msg.sender : ",IGuardian(guardian).f00000000_bvvvdlt());
        console.log("address(this) : ",IGuardian(guardian).f00000001_grffjzz());

        require(
            IGuardian(guardian).f00000000_bvvvdlt() == address(this),
            "invalid pass"
        );
        require(
            IGuardian(guardian).f00000001_grffjzz() == tx.origin,
            "invalid 2nd pass"
        );

        (bool success, ) = guardian.call(abi.encodeWithSignature("fail()"));
        console.log(" success : ", success);
        require(!success);

        opened = true;
    }
}
/**
 * PUSH1 00 // 0
CALLDATALOAD // 2
PUSH1 0xE0 //3
SHR //5

DUP1 //6
PUSH4 0x00000000 //7
EQ // 9
PUSH1 31 //10
JUMPI // 12

DUP1 //13
PUSH4 0x00000001 //14
EQ // 22
PUSH1 39 //23
JUMPI //25

PUSH1 00 // 26
PUSH1 00 // 28
REVERT // 30

JUMPDEST //31
ADDRESS // 32
PUSH1 00// 33
MSTORE // 35
PUSH1 44 // 36
JUMP // 38

JUMPDEST //39
ORIGIN
PUSH1 00 // 42
MSTORE // 44
 
JUMPDEST // 45
PUSH1 32
PUSH1 00 //  48
RETURN // 
 */

/**
 * PUSH1 00 // 0
CALLDATALOAD // 2
PUSH1 0xE0 // 3
SHR // 5

DUP1 //6
ISZERO
PUSH1 18// 10
JUMPI //12

PUSH1 01
EQ
PUSH1 
JUMP

ORIGIN //13
PUSH1 00//14
MSTORE//16
PUSH1 23//17      // jump to common RETURN at 31
JUMP // 19

JUMPDEST  //20      // <-- NOT 31
ADDRESS // 21
PUSH1 00 // 22
MSTORE //24

JUMPDEST  //25      // common return
PUSH1 32 //26
PUSH1 00 //28
RETURN // 30
want to constrain this inisde the 32 byte with revert 
 */
