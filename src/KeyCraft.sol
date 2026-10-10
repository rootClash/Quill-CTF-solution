// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {console} from "forge-std/console.sol";

contract KeyCraft is ERC721 {
    uint totalSupply;
    address owner;
    bool buyNFT;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {
        _mint(msg.sender, totalSupply++);
        owner = msg.sender;
    }

    modifier checkAddress(bytes memory b) {
        bool q;
        bool w;

        if (msg.sender == owner) {
            buyNFT = true;
        } else {
            uint a = uint160(uint256(keccak256(b)));
            q = (address(uint160(a)) == msg.sender);
            console.log("q : ",q);
            console.log("msg.sender : ", msg.sender);
            console.log("a : ", a);
            console.log("True originated!");
            a = a >> 108;
            a = a << 240;
            a = a >> 240;

            // 0x3301 == 13057
            // Address:0x0000000003301000000000000000000000000000
            w = (a == 13057);
        }

        buyNFT = (q && w) || buyNFT;
        _;
        buyNFT = false;
    }

    function mint(bytes memory b) public payable checkAddress(b) {
        require(msg.value >= 1 ether || buyNFT, "Not allowed to mint.");
        _mint(msg.sender, totalSupply++);
    }

    function burn(uint tok) public {
        address a = ownerOf(tok);
        require(msg.sender == a);
        _burn(tok);
        totalSupply--;
        payable(a).transfer(1 ether);
    }
}