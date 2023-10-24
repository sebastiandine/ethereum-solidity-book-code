// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ERC721Opz is ERC721 {

    uint256 nextTokenId;
    mapping(uint256=>string) private tokenIdToUri;

    constructor(string memory _name, string memory _symbol) 
        ERC721(_name, _symbol){}
    
    function mint(string memory tokenUri) external {
        _safeMint(msg.sender, nextTokenId);
        tokenIdToUri[nextTokenId] = tokenUri;
        nextTokenId += 1;

    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return tokenIdToUri[tokenId];
    }
}
