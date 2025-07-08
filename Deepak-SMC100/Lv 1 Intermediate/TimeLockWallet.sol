// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeWallet {

    // State variables
    address public owner;          // Owner of the wallet
    uint public unlockTime;       // Timestamp after which withdrawal is allowed

    // Constructor sets unlock time and assigns ownership
    constructor(uint _unlockTime) {
        unlockTime = block.timestamp + _unlockTime; // lock duration added to current time
        owner = msg.sender;
    }

    // Modifier to restrict access to owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can withdraw tokens");
        _;
    }

    // Allow contract to receive Ether via direct transfer or fallback call
    receive() external payable {}
    fallback() external payable {}

    // Event to log successful withdrawals
    event TransferLog(uint withdrawalAmt, address recipient);

    // Withdraw function: only callable by owner after unlockTime
    function withdraw(uint withdrawAmt) external onlyOwner {
        require(block.timestamp >= unlockTime, "Too early to withdraw");
        require(address(this).balance >= withdrawAmt, "Insufficient balance");

        payable(owner).transfer(withdrawAmt);

        emit TransferLog(withdrawAmt, owner);
    }

    // Returns the lock status as a human-readable string
    function lockStatus() public view returns (string memory) {
        if (block.timestamp < unlockTime) {
            return "Wallet is Locked";
        } else {
            return "Wallet is now Unlocked";
        }
    }

    // Returns the current balance of the contract
    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }
}

