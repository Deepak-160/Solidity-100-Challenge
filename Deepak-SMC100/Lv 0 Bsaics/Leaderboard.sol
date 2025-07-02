
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* 
   This contract manages a simple leaderboard system.
   It allows adding addresses with scores, rearranging positions, 
   and replacing the last address with a new one.
   Educational purpose only.
*/

contract Leaderboard {

    // Dynamic array to store addresses participating in the leaderboard
    address[] public leaderBoard;

    // Mapping to quickly check if an address already exists in the leaderboard
    mapping(address => bool) public doesExist;

    // Mapping to store the score associated with each address
    mapping(address => uint) public score;

    /*
        Function to add a new address with its score.
        Fails if the address is already present.
    */
    function addAddressWithScore(address adress, uint _score) public {
        require(!doesExist[adress], "Address already exists");

        // Append the new address to the array
        leaderBoard.push(adress);

        // Set the score for this address
        score[adress] = _score;

        // Mark the address as existing
        doesExist[adress] = true;
    }

    /*
        Function to swap two addresses' positions in the leaderboard array.
        You must manually pass their new scores.
    */
    function rearrangeAddresses(
        uint _i,
        uint _scoreOf_i,
        uint _ii,
        uint _scoreOf_ii
    ) public {
        // Ensure indices are valid
        require(
            _i < leaderBoard.length && _ii < leaderBoard.length,
            "Array index is too large. One or both indices do not exist"
        );

        // Temporarily store the addresses at positions _i and _ii
        address temp1 = leaderBoard[_i];
        address temp2 = leaderBoard[_ii];

        // Swap addresses in the array
        leaderBoard[_i] = temp2;
        score[leaderBoard[_i]] = _scoreOf_i; // Assign new score to the swapped-in address

        leaderBoard[_ii] = temp1;
        score[leaderBoard[_ii]] = _scoreOf_ii; // Assign new score to the swapped-in address
    }

    /*
        Function to remove the last address and add a new address in its place.
        This simulates adding a fresh competitor and evicting the lowest one.
    */
    function addNewAddress(address adress, uint _score) public {
        // Retrieve the address to be removed
        address removed = leaderBoard[leaderBoard.length - 1];

        // Mark the removed address as no longer existing
        doesExist[removed] = false;

        // Clear the score of the removed address
        score[removed] = 0;

        // Make sure the new address does not already exist
        require(!doesExist[adress], "This address already exists. You can't add it twice.");

        // Remove the last element from the array
        leaderBoard.pop();

        // Append the new address
        leaderBoard.push(adress);

        // Mark the new address as existing and set its score
        doesExist[adress] = true;
        score[adress] = _score;
    }

    /*
        Function to return the entire leaderboard array.
        Allows external users to view the leaderboard.
    */
    function seeLeaderboard() public view returns(address[] memory) {
        return leaderBoard;
    }
}
