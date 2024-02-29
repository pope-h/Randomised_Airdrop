# SocialMedia Smart Contract

This is a Solidity smart contract that simulates a social media platform with Non-Fungible Tokens (NFTs). Users can create, share, like, and comment on NFTs. The contract also includes a feature for airdropping NFTs to users.

## Contract Structure

The contract imports three other contracts: `NFTFactory`, `UserAuthentication`, and `RandomWinner`. It uses these contracts to mint NFTs, authenticate users, and select random winners for airdrops, respectively.

The contract defines a struct `NFT` that represents an NFT on the platform. Each NFT has an owner, an ID, a number of likes, a list of addresses that liked it, a list of comments, and a flag indicating whether it has been shared.

The contract maintains a mapping from NFT IDs to NFTs and a counter of the total number of NFTs. It also maintains a mapping and an array of addresses eligible for airdrops.

## Functions

The contract provides the following functions:

- `createNFT`: Creates a new NFT owned by the sender.
- `shareNFT`: Allows the owner of an NFT to share it.
- `likeNFT`: Allows a user to like a shared NFT.
- `commentOnNFT`: Allows a user to comment on a shared NFT.
- `getOwnNFTIndex`: Returns the IDs of the NFTs owned by the sender.
- `getNFTLikes`: Returns the number of likes of an NFT.
- `getNFTComments`: Returns the comments of an NFT.
- `checkNFTQualifies`: Checks whether an NFT qualifies for airdrop (it must have at least 2 likes and 1 comment).
- `addToAirdrop`: Adds the sender to the list of addresses eligible for airdrop if they own a qualifying NFT.
- `selectWinner`: Selects a random address from the list of addresses eligible for airdrop.
- `mintWinnerNFT`: Mints a new NFT and transfers it to the winner.

## Events

The contract emits the following events:

- `NFTCreated`: Emitted when a new NFT is created.
- `NFTShared`: Emitted when an NFT is shared.
- `NFTLiked`: Emitted when an NFT is liked.
- `NFTCommentAdded`: Emitted when a comment is added to an NFT.

## Requirements

To interact with this contract, users must be logged in and have a username (as checked by the `UserAuthentication` contract). To like or comment on an NFT, the NFT must have been shared. To qualify for airdrop, an NFT must have at least 2 likes and 1 comment.