// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./NFTFactory.sol";
import "./UserAuthentication.sol";
import "./RandomWinner.sol";

contract SocialMedia {
    NFTFactory nftFactory;
    UserAuthentication userAuth;

    mapping(address => bool) public airdropAddresses;
    address[] public airdropAddressesArray;
    RandomWinner randomWinner;

    struct NFT {
        address owner;
        uint256 nftId;
        uint256 likes;
        mapping(address => bool) likedBy;
        string[] comments;
        bool isShared; // New field to track if the NFT has been shared
    }

    mapping(uint256 => NFT) public nfts;
    uint256 public totalNFTs;
    
    event NFTCreated(uint256 indexed nftId, address indexed owner);
    event NFTShared(uint256 indexed nftId, address indexed owner);
    event NFTLiked(uint256 indexed nftId, address indexed liker);
    event NFTCommentAdded(uint256 indexed nftId, address indexed commenter, string comment);

    constructor(address _nftFactoryAddress, address _userAuthAddress, address _randomWinnerAddress) {
        nftFactory = NFTFactory(_nftFactoryAddress);
        userAuth = UserAuthentication(_userAuthAddress);

        randomWinner = RandomWinner(_randomWinnerAddress);
    }

    function createNFT(string memory _tokenURI) public {
        require(userAuth.isLoggedIn(msg.sender), "User not logged in");
        require(bytes(userAuth.attachedUserName(msg.sender)).length > 0, "User must have a username");

        uint256 nftId = nftFactory.mintNFT(msg.sender, _tokenURI);
        NFT storage nft = nfts[nftId];

        nft.owner = msg.sender;
        nft.nftId = nftId;
        nft.likes = 0;
        nft.comments = new string[](0);
        nft.isShared = false; // Set to false initially

        totalNFTs++;

        emit NFTCreated(nftId, msg.sender);
    }

    function shareNFT(uint256 _nftId) public {
        require(_nftId < totalNFTs, "Invalid NFT ID");

        NFT storage nft = nfts[_nftId];
        require(nft.owner == msg.sender, "You are not the owner of this NFT");
        require(!nft.isShared, "NFT has already been shared");

        nft.isShared = true;

        emit NFTShared(_nftId, msg.sender);
    }

    function likeNFT(uint256 _nftId) public {
        require(_nftId < totalNFTs, "Invalid NFT ID");

        NFT storage nft = nfts[_nftId];
        require(nft.isShared, "NFT has not been shared yet");

        require(userAuth.isLoggedIn(msg.sender), "User not logged in");
        require(bytes(userAuth.attachedUserName(msg.sender)).length > 0, "User must have a username");
        require(!nft.likedBy[msg.sender], "Already liked");

        nft.likedBy[msg.sender] = true;
        nft.likes++;

        emit NFTLiked(_nftId, msg.sender);
    }

    function commentOnNFT(uint256 _nftId, string memory _comment) public {
        require(_nftId < totalNFTs, "Invalid NFT ID");

        NFT storage nft = nfts[_nftId];
        require(nft.isShared, "NFT has not been shared yet");

        require(userAuth.isLoggedIn(msg.sender), "User not logged in");
        require(bytes(userAuth.attachedUserName(msg.sender)).length > 0, "User must have a username");

        nft.comments.push(_comment);

        emit NFTCommentAdded(_nftId, msg.sender, _comment);
    }

    function getOwnNFTIndex() external view returns (uint256[] memory) {
        uint256[] memory ownNFTIndexes = new uint256[](totalNFTs);
        uint256 counter = 0;

        for (uint256 i = 0; i < totalNFTs; i++) {
            if (nfts[i].owner == msg.sender) {
                ownNFTIndexes[counter] = i;
                counter++;
            }
        }

        // Trim the array to remove any unused slots
        uint256[] memory result = new uint256[](counter);
        for (uint256 j = 0; j < counter; j++) {
            result[j] = ownNFTIndexes[j];
        }

        return result;
    }

    function getNFTLikes(uint256 _nftId) external view returns (uint256) {
        require(_nftId < totalNFTs, "Invalid NFT ID");

        NFT storage nft = nfts[_nftId];
        return nft.likes;
    }

    function getNFTComments(uint256 _nftId) external view returns (string[] memory) {
        require(_nftId < totalNFTs, "Invalid NFT ID");

        NFT storage nft = nfts[_nftId];
        return nft.comments;
    }

    function checkNFTQualifies(uint256 _nftId) public view returns (bool) {
        NFT storage nft = nfts[_nftId];
        return nft.likes >= 2 && nft.comments.length >= 1;
    }

    function addToAirdrop(uint256 _nftId) public {
        require(checkNFTQualifies(_nftId), "NFT does not qualify for airdrop");
        if (!airdropAddresses[msg.sender]) {
            airdropAddresses[msg.sender] = true;
            airdropAddressesArray.push(msg.sender);
        }
    }

    function selectWinner() public returns (address) {
        require(airdropAddressesArray.length > 0, "No addresses in the airdrop");
        uint256 winnerIndex = randomWinner.requestRandomWords() % airdropAddressesArray.length;
        return airdropAddressesArray[winnerIndex];
    }

    function mintWinnerNFT(string memory _tokenURI) public {
        address winner = selectWinner();
        createNFT(_tokenURI);
        nftFactory.transferFrom(address(this), winner, totalNFTs - 1);
    }
}