//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyContract {

    struct Contribution {
        address Address;
        uint Amount;
    }

    Contribution[] contributions;

    mapping(address => bool) public hasPaid;
    mapping(address => uint) public contributor;
    address[] public contributors;

    address public owner;
    uint public MinAmount = 0.001 ether;
    uint public goalAmount = 50 ether;
    uint timeLimit = block.timestamp + 2538000;

    bool public isActive = true;
    bool public eventEnd = false;

    event donation(address, uint);
    event refund(address, uint);
    event ownerWithdrawal(address, uint);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function daysLeft() public view returns (uint) {
        // Returns days left until deadline
        uint deadLine = (timeLimit - block.timestamp) / 86400;
        return deadLine;
    }

    function fundraised() public view returns (uint) {
        // Total ETH raised so far
        return address(this).balance;
    }

    function Pay() external payable returns (string memory) {
        require(eventEnd == false, "Fundraising event is closed you cannot pay now");
        require(isActive == true, "Event is terminated,We are sorry");
        require(msg.value >= 0.001 ether, "please pay the valid amount");

        contributions.push(Contribution(msg.sender, msg.value));
        contributor[msg.sender] += msg.value;

        if (!hasPaid[msg.sender]) {
            contributors.push(msg.sender);
            hasPaid[msg.sender] = true;
        }

        emit donation(msg.sender, msg.value);
        string memory Str = "thanks for contributing We received your payment";
        return Str;
    }

    function SeeContributions() public view returns (Contribution[] memory) {
        // Return all contributions
        return contributions;
    }

    function terminate_Operation() public onlyOwner {
        // Disable further contributions
        isActive = false;
    }

    function endEvent() public onlyOwner {
        // Mark event as concluded
        eventEnd = true;
    }

    function Refund(address _YourAddress) public returns (string memory) {
        require(isActive == false, "you cannot take your refund while the fundraising event is still active");
        require(hasPaid[_YourAddress] == true, "you have never participated in any contribution");

        string memory Str1 = "You are eligible,Payment successfully sent to your wallet";
        string memory Str2 = "You are ineligible";

        if (hasPaid[_YourAddress] == true) {
            uint tempAmt = contributor[_YourAddress];
            contributor[_YourAddress] = 0;
            payable(_YourAddress).transfer(tempAmt);
            emit refund(_YourAddress, tempAmt);
            hasPaid[_YourAddress] = false;
            return Str1;
        } else {
            return Str2;
        }
    }

    function ownerWithdraw() public payable onlyOwner {
        require(eventEnd == true, "Fundraising event has not ended yet.");
        payable(owner).transfer(address(this).balance);
        delete contributions;
    }
}

