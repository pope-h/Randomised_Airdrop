# Guessing Game

This is a simple guessing game implemented in Solidity. Players can register, make a guess, and if they guess correctly, they win a prize.

## Contract

The main contract is `GuessingGame`. It inherits from `VRFConsumerBaseV2` and `ConfirmedOwner` from the Chainlink contracts.

### Events

- `PlayerRegistered`: Emitted when a player registers.
- `GuessResult`: Emitted when a player makes a guess.
- `PrizesDistributed`: Emitted when prizes are distributed.
- `RequestSent`: Emitted when a random number request is sent.
- `RequestFulfilled`: Emitted when a random number request is fulfilled.
- `RandomWordsRequested`: Emitted when random words are requested.

### Functions

- `register`: Registers a player.
- `guessNumber`: Makes a guess.
- `distributePrizes`: Distributes prizes to winners.
- `getPrevWinners`: Returns the previous winners.
- `requestRandomWords`: Requests random words from the Chainlink VRF.
- `fulfillRandomWords`: Callback function for the Chainlink VRF.
- `getRequestStatus`: Returns the status of a random number request.

## Setup

First, install the dependencies:

```bash
npm install

To compile the contract, use:

npx hardhat compile

To deploy the contract, use:

npx hardhat run scripts/deploy.js --network <network-name>

To run the tests, use:

npx hardhat test

GuessingGame contract deployed to 0xcbD8C978055d9DB2F478bd3ea51dFc693CC6dF54