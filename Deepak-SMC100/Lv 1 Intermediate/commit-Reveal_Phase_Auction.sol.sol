//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyContract {

    uint commitEnd;                       // End time of commit phase
    uint revealEnd;                       // End time of reveal phase
    uint highestBid;                      // Current highest bid
    address highestBidder;                // Current highest bidder
    address public Auctioneer;            // Auction creator

    mapping(address => bytes32) public HashValue;    // Stores hash(commitment) of each bidder
    mapping(address => uint) public paidValue;       // Stores value locked by each bidder
    mapping(address => bool) public commited;        // Tracks if bidder has committed

    event AuctionWinner(address Address, uint bidAmount);

    constructor(uint _commitDuration, uint _revealDuration) {
        commitEnd = block.timestamp + _commitDuration;   // Commit phase deadline
        revealEnd = commitEnd + _revealDuration;         // Reveal phase deadline
        Auctioneer = msg.sender;                         // Auctioneer = deployer
    }

    modifier onlyOwner() {
        require(msg.sender == Auctioneer, "Only Auctioneer can perforn this action");
        _;
    }

    // --- Commit Phase ---
    function commitBid(bytes32 _secretHash) external payable {
        require(block.timestamp < commitEnd, "Bidding is Closed");
        require(commited[msg.sender] == false, "You have commited before");

        HashValue[msg.sender] = _secretHash;
        paidValue[msg.sender] = msg.value;
        commited[msg.sender] = true;
    }

    // --- Reveal Phase ---
    function reveal(uint _paidAmount, string calldata _secretSalt) external {
        require(commited[msg.sender] == true, "you are not a participent");
        require(block.timestamp > commitEnd, "commit phase is still running");
        require(block.timestamp < revealEnd, "The reveal phase has ended");

        require(paidValue[msg.sender] == _paidAmount, "Amount Mismatch");

        // Recreate commitment hash
        bytes32 expectedHash = keccak256(
            abi.encodePacked(_paidAmount, _secretSalt, msg.sender)
        );

        require(HashValue[msg.sender] == expectedHash, "Your Hash Mismatched");

        // Case 1: Higher bid than current highest
        if (_paidAmount > highestBid) {
            address prevBidder = highestBidder;
            uint prevBid = highestBid;

            // Refund previous highest bidder
            if (prevBidder != address(0)) {
                (bool ok,) = payable(prevBidder).call{value: prevBid}("");
                require(ok, "Refund Failed");

                highestBid = _paidAmount;
                highestBidder = msg.sender;
            }

            paidValue[msg.sender] = 0;
        }

        // Case 2: Lower than highest bid -> refund back
        if (_paidAmount < highestBid) {
            uint tempValue = paidValue[msg.sender];
            paidValue[msg.sender] = 0;
            commited[msg.sender] = false;  
            HashValue[msg.sender] = 0;

            (bool ok,) = payable(msg.sender).call{value: tempValue}("");  
            require(ok, "Refund Failed"); 
            // `.call{value: X}("")` → sends ether & returns (success flag, data).
            // We only check `success` (bool ok). The returned data is ignored here.
        }
    }

    // --- Auction Finalization ---
    function AuctionFinalize() public onlyOwner {
        require(block.timestamp > revealEnd, "Auction is still Running");

        emit AuctionWinner(highestBidder, highestBid);

        // Transfer final winning bid to Auctioneer
        (bool ok,) = payable(Auctioneer).call{value: highestBid}("");
        require(ok, "transaction Failed");
    } 
}
