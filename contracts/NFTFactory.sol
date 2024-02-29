// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTFactory is ERC721URIStorage {
    uint256 public tokenIdCounter;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function mintNFT(address _to, string calldata _tokenURI) external returns(uint) {
        uint256 newTokenId = tokenIdCounter;
        _safeMint(_to, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        tokenIdCounter++;
        return newTokenId;
    }
}