//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;


/** *
 * 
*/

  //custom error

    error Raffile_SendMoreToEnterRaffile();

contract Raffile{

  

uint256 private immutable I_enteranceFee;
uint256 private immutable i_interval;
uint256 private immutable i_lastTimeStamp
address payable[] private s_players;

 /*Event*/

 event RaffileEntered(address indexed player)


constructor(uint256 enteranceFee,uint256 _interval){
    I_enteranceFee = enteranceFee;
    i_inverval = _interval;
    i_lastTimeStamp = block.timestamp
}






function enterRaffile()external payable{

// check more about this two revert type plese this is knda expen thatn if
    //require(msg.value >= I_enteranceFee, SendMoreToEnterRaffile());

    if(msg.value <  I_enteranceFee){
        revert Raffile_SendMoreToEnterRaffile();
    }
    s_players.push(msg.sender)
     emit RaffileEntered(msg.sender)

}

function pickWinner()external{
    if((block.timestamp - i_lastTimeStamp) <  i_interval){
        revert();
    }

}


function getEnteranceFee()public view returns(uint256){
    return I_enteranceFee;
}


}
