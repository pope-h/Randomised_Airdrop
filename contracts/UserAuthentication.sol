// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./NFTFactory.sol";

contract UserAuthentication {
    NFTFactory public nftFactory;
    mapping(address => string) public attachedUserName;
    mapping(address => bool) public isLoggedIn;
    mapping(address => string) public userRoles;

    event UserRegistered(address indexed user, string username);

    modifier onlyAdmin() {
        require(keccak256(abi.encodePacked(userRoles[msg.sender])) == keccak256(abi.encodePacked("admin")), "Not authorized");
        _;
    }

    modifier userHasRole(address _user) {
        require(bytes(userRoles[_user]).length > 0, "User does not have a role assigned");
        _;
    }

    modifier userHasUserName() {
        require(bytes(attachedUserName[msg.sender]).length > 0, "User does not have a username set");
        _;
    }

    modifier userIsLoggedIn() {
        require(isLoggedIn[msg.sender], "User is not logged in");
        _;
    }

    constructor(address _nftFactoryAddress) {
        nftFactory = NFTFactory(_nftFactoryAddress);
        userRoles[msg.sender] = "admin";
    }

    function assignRole(address _user, string memory _role) public onlyAdmin {
        userRoles[_user] = _role;
    }

    function revokeRole(address _user) public onlyAdmin {
        delete userRoles[_user];
    }

    function attachUserName(string memory _username) external userHasRole(msg.sender) {
        require(bytes(_username).length > 0, "Username cannot be empty");
        require(bytes(attachedUserName[msg.sender]).length == 0, "User already registered");

        attachedUserName[msg.sender] = _username;
        emit UserRegistered(msg.sender, _username);
    }

    // The function below is used for when a wallet is connected
    // In essence this will be set to true once a user connects their wallet
    function login() external userHasUserName {
        isLoggedIn[msg.sender] = true;
    }

    function logout() external userIsLoggedIn {
        isLoggedIn[msg.sender] = false;
    }

    function getTokenIdCounter() external view returns(uint256) {
        return nftFactory.tokenIdCounter();
    }
}