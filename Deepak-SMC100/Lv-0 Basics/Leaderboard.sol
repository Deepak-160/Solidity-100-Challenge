//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

 /* “Here’s a Solidity practice contract demonstrating leaderboard management using arrays and mappings. 
Educational purpose only. Open to feedback!” */  


contract Leaderboard{

    address[] public leaderBoard;

    mapping(address => bool) public doesExist;

    mapping(address => uint) public score;

    function addAddressWithScore(address adress,uint _score) public {

        require(!doesExist[adress], "Address already exists");

        leaderBoard.push(adress);
        score[adress] = _score;
        doesExist[adress]= true;
    }

    function rearrangeAddresses(uint _i,uint _scoreOf_i,uint _ii,uint _scoreOf_ii) public {

        require (_i < leaderBoard.length && _ii < leaderBoard.length,"array index is too large. any one or both indices does not exist");

        address temp1;
        address temp2;

        

        temp1 = leaderBoard[_i];
        temp2 = leaderBoard[_ii];

        leaderBoard[_i] = temp2;
        score[leaderBoard[_i]] = _scoreOf_i;

        leaderBoard[_ii] = temp1;
        score[leaderBoard[_ii]] = _scoreOf_ii;
    }

    function addNewAddress(address adress,uint _score) public{

        

        address removed = leaderBoard[leaderBoard.length -1];

        doesExist[removed] = false;

        score[removed] = 0;

        require(doesExist[adress] != true,"This address already Exist,You cant add this twice");

        leaderBoard.pop();

        leaderBoard.push(adress);

        doesExist[adress] = true;

        score[adress] = _score;


    }

    function seeLeaderboard() public view returns(address[] memory){

        return leaderBoard;    
          
  }
}
