// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

contract GuessingGame is VRFConsumerBaseV2, ConfirmedOwner {
    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }

    struct Player {
        uint256 attempts;
        bool active;
    }

    mapping(uint256 => RequestStatus) s_requests; /* requestId --> requestStatus */
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // past requests Id.
    uint256[] requestIds;
    uint256 public lastRequestId;

    uint256 lastRequestTime;

    bytes32 keyHash =
        0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;

    uint32 callbackGasLimit = 300000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 2;

    mapping(address => Player) public players;
    address[] public playerAddresses;
    uint256 public totalPrize;
    address[] winners;
    address[] public prevWinners;

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);
    event GuessResult(address indexed player, uint guess, uint randomNumber, string result);
    event PlayerRegistered(address indexed player);
    event PrizesDistributed(address[] winners, uint256 prizeAmount);
    event RandomWordsRequested(uint256 requestId);

    constructor(
        uint64 subscriptionId
    )
        VRFConsumerBaseV2(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625)
        ConfirmedOwner(msg.sender)
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
        );
        s_subscriptionId = subscriptionId;
    }

    function register() public payable {
        require(msg.value == 20000000000000000 wei, "Please stake 20000000000000000 wei");
        totalPrize += msg.value;
        players[msg.sender] = Player(0, true); // Initialize attempts to 0
        playerAddresses.push(msg.sender);
        
        emit PlayerRegistered(msg.sender);
    }

    function guessNumber(uint256 guess) public {
        require(guess > 0 && guess <= 9, "Number must be between 1 and 9");
        Player storage player = players[msg.sender];
        require(player.active, "Player is not active");
        require(player.attempts < 2, "Player has already made 2 attempts");

        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 10 + 1;

        player.attempts += 1;

        if (guess == randomNumber) {
            playerAddresses.push(msg.sender);
            player.attempts = 2;
            emit GuessResult(msg.sender, guess, randomNumber, "Correct guess");
        } else {
            emit GuessResult(msg.sender, guess, randomNumber, "Wrong guess");
        }
    }

    function distributePrizes() public {
        require(lastRequestId != 0, "requestRandomWords not called yet");
        require(block.timestamp > lastRequestTime + 40, "Wait a bit longer or recall requestRandomWords after sometime");
        (bool fulfilled, uint256 randomNumber1, uint256 randomNumber2) = getRequestStatus(lastRequestId);
        require(fulfilled, "Random number not yet available");

        winners.push(playerAddresses[randomNumber1 % playerAddresses.length]);
        winners.push(playerAddresses[randomNumber2 % playerAddresses.length]);

        prevWinners.push(playerAddresses[randomNumber1 % playerAddresses.length]);
        prevWinners.push(playerAddresses[randomNumber2 % playerAddresses.length]);

        uint prize = totalPrize / winners.length;
        for (uint i = 0; i < winners.length; i++) {
            payable(winners[i]).transfer(prize);
        }

        emit PrizesDistributed(winners, prize);

        delete playerAddresses;
        delete winners;
        totalPrize = 0;
        lastRequestId = 0; // Reset the requestId for the next round
    }

    function getPrevWinners() public view returns (address[] memory) {
        return prevWinners;
    }

    function requestRandomWords()
        public
        onlyOwner
        returns (uint256 requestId)
    {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        lastRequestTime = block.timestamp;
        emit RequestSent(requestId, numWords);

        emit RandomWordsRequested(requestId);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        for (uint256 i = 0; i < _randomWords.length; i++) {
        // Generate a random number between 1 and 3
            _randomWords[i] = _randomWords[i] % 10;
        }
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(uint256 _requestId) public view returns (bool fulfilled, uint256 randomNumber1, uint256 randomNumber2) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords[0], request.randomWords[1]);
    }
}