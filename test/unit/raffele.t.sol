//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test,console} from 'forge-std/Test.sol';
import {DeployRaffile} from 'script/DeployRaffle.s.sol';
import {Raffile} from 'src/Raffle.sol';
import {HelperConfig} from 'script/HelperConfig.s.sol';



contract RaffileTest is  Test{
    Raffile raffle;
    HelperConfig helperConfig;

      uint256 enteranceFee;
        uint256 interval;
        address vrfCodination;
        bytes32 gaslane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;

address public PLAYER = makeAddr('player');
uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

  event RaffileEntered(address indexed player);
    event WinerPicked(address indexed winner);


function setUp()external {
    DeployRaffile deployer =  new DeployRaffile();
    (raffle,helperConfig) = deployer.run();
  HelperConfig.NetWorkConfig memory  config = helperConfig.getConfig(); 
    

   enteranceFee = config.entranceFee;
   interval = config.interval;
   vrfCodination = config.vrfCoordination;
   gaslane = config.gaslane;
   callbackGasLimit = config.callbackGasLimit;
   subscriptionId = config.subscriptionId;
 vm.deal(PLAYER,STARTING_PLAYER_BALANCE);
}

function testRafileInitializesInOpenState() external view{

 //assertEq(uint256(raffle.getRaffileState()),0);
 //or
 assert(raffle.getRaffileState() == Raffile.RaffileState.Open);

//console.log(raffle.getRaffileState());


}



function testRaffileRevertWhenYouDontPayEnough()external{
//check more about selector
vm.expectRevert(Raffile.Raffile_SendMoreToEnterRaffile.selector);
vm.prank(PLAYER);
raffle.enterRaffile();



}


function testRaffileRecordPlayerWhenEnterRaffile()external{
vm.prank(PLAYER);
raffle.enterRaffile{value: enteranceFee}();

assert(raffle.getPlayers(0) == PLAYER);

}


function testEnteringRaffileEmitsEvent() external{
vm.prank(PLAYER);
// the expectmit accept 5 prameters first 3 are true or false depend  if you have 3 indexed event,
// the 4th is true of false if u have non indexed event , and the last the  the CA of the contracts


vm.expectEmit(true, false, false, false,address(raffle));

// the we emit the event we expec below it

emit RaffileEntered(PLAYER);

raffle.enterRaffile{value: enteranceFee}();
 
}




}