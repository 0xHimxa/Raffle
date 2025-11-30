//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test,console} from 'forge-std/Test.sol';
import {DeployRaffile} from 'script/DeployRaffle.s.sol';
import {Raffile} from 'src/Raffle.sol';
import {HelperConfig} from 'script/HelperConfig.s.sol';
import {Vm} from 'forge-std/Vm.sol';




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


function testDontAllowToEnterRaffileWhilePickingWinner()external{

vm.prank(PLAYER);

raffle.enterRaffile{value: enteranceFee}();
//vm.warp allow us to time travel or manipulate the time to reach 
//the realse time so we can test it
vm.warp(block.timestamp + interval + 1);
// this one we wait for block confarmation // to jump to certain block eg
// if token can be relsease after 500mines block we can jump to that with roll
vm.roll(block.number + 1);

raffle.performUpkeep();

vm.expectRevert(Raffile.Raffile__NotOPen.selector);
raffle.enterRaffile{value: enteranceFee}();

}
 function testcheckUpkeepReturnsTrue() external{
  vm.prank(PLAYER);

raffle.enterRaffile{value: enteranceFee}();
vm.warp(block.timestamp + interval + 1);
vm.roll(block.number + 1);

(bool upkeep,) = raffle.checkUpKeep('');

assert(upkeep == true);
 }



 function testcheckUpkeepReturnsfalse() external{



(bool upkeep,) = raffle.checkUpKeep('');
vm.warp(block.timestamp + interval + 1);
vm.roll(block.number + 1);

assert(!upkeep);
 }



 function testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue()external{
 vm.prank(PLAYER);

raffle.enterRaffile{value: enteranceFee}();
vm.warp(block.timestamp + interval + 1);
vm.roll(block.number + 1);

// we can leave it like this if it pass i wil work else it will fail
raffle.performUpkeep();


 }

function testPerformUpkeepRevertIfCheckUpkeepIsFalse()external {
 vm.prank(PLAYER);

raffle.enterRaffile{value: enteranceFee}();

uint256 balance = address(raffle).balance;

uint256 numplayers = 1;
//we use this abi stuff if our custom error accept param
vm.expectRevert(abi.encodeWithSelector(Raffile.Raffile__UpkeepNotNeeded.selector,balance,numplayers));


raffle.performUpkeep();







}


modifier raffleEntered(){
   vm.prank(PLAYER);

raffle.enterRaffile{value: enteranceFee}();
vm.warp(block.timestamp + interval + 1);
vm.roll(block.number + 1);
_;
}





function testPerformUpKeepUpdateRaffleStateAndEmitRequestedId()external raffleEntered{



//vm.recoardlogs = record  and stick them to an array what ever log of event that is been emitter below it

vm.recordLogs();
raffle.performUpkeep();

//vm.getrecorded the the recored logs from vm.record, 

Vm.Log[] memory enteries = vm.getRecordedLogs();


//go to the Vm.Log file for more info or ask ai

//anything return from the getlogs will be in bytes32

//to get our request id from the log

//the first index are reserved for vrf so we start from 1
bytes32 requestId = enteries[1].data[1];
//console.log(requestId);


Raffile.RaffileState s_raffleState = raffle.getRaffileState();

assert(uint256(requestId) > 0);
assert(s_raffleState == Raffile.RaffileState.Calculating);



}







}