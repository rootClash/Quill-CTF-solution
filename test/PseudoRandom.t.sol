// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/PseudoRandom.sol";

contract PseudoRandomTest is Test {
    address private addr;
    
    string private BSC_RPC = "https://rpc.ankr.com/bsc/"; // 56
    string private POLY_RPC = "https://rpc.ankr.com/polygon/"; // 137
    string private FANTOM_RPC = "https://rpc.ankr.com/fantom/"; // 250
    string private ARB_RPC = "https://rpc.ankr.com/arbitrum/"; // 42161
    string private OPT_RPC = "https://rpc.ankr.com/optimism/"; // 10
    string private GNOSIS_RPC = "https://rpc.ankr.com/gnosis/"; // 100

    string api;
    function setUp() external {
        api = vm.envString("API_KEY");
        string memory Rpc = string.concat(
            BSC_RPC,
            api
        );
        vm.createSelectFork(Rpc);
    }

    function test_Random() external {
        string memory rpc = new string(32);
        assembly {
            // network selection
            let _rpc := sload(
                add(mod(xor(number(), timestamp()), 0x06), BSC_RPC.slot)
            )
            mstore(rpc, shr(0x01, and(_rpc, 0xff)))
            mstore(add(rpc, 0x20), and(_rpc, not(0xff)))
        }

        addr = makeAddr(rpc);
        string memory _rpc = string.concat(
            rpc,
            api            
        );
        vm.createSelectFork(_rpc);
        console.log("rpc : ", _rpc);

        // msg.sender, tx.origin
        vm.startPrank(addr, addr);
        //  sload(sload(add(chainid(), caller())))
        address instance = address(new PseudoRandom());

        bytes32 slot1 = vm.load(address(instance) ,  bytes32(uint256(block.chainid + uint256(uint160(addr)))));
        bytes32 slot2 = vm.load(address(instance) , slot1);

        console.log("byte4 value");
        console.logBytes32(bytes32(slot2));

        (bool success , ) = instance.call(abi.encodeWithSelector(bytes4(slot2),uint256(1),address(addr)));
        require(success , "Not success");

        vm.stopPrank();
        // the solution 
        
        assertEq(PseudoRandom(instance).owner(), addr);
    }
}