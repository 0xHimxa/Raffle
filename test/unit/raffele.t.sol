//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployRaffile} from "script/DeployRaffle.s.sol";
import {Raffile} from "src/Raffle.sol";
import {HelperConfig,CodeConstant} from "script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";

import {
    VRFCoordinatorV2_5Mock
} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract RaffileTest is Test,CodeConstant {
    Raffile raffle;
    HelperConfig helperConfig;

    uint256 enteranceFee;
    uint256 interval;
    address vrfCodination;
    bytes32 gaslane;
    uint256 subscriptionId;
    uint32 callbackGasLimit;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    event RaffileEntered(address indexed player);
    event WinerPicked(address indexed winner);
    event RequestRaffileWinner(uint256 indexed requestId);

    function setUp() external {
        DeployRaffile deployer = new DeployRaffile();
        (raffle, helperConfig) = deployer.run();
        HelperConfig.NetWorkConfig memory config = helperConfig.getConfig();

        enteranceFee = config.entranceFee;
        interval = config.interval;
        vrfCodination = config.vrfCoordination;
        gaslane = config.gaslane;
        callbackGasLimit = config.callbackGasLimit;
        subscriptionId = config.subscriptionId;
        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    function testRafileInitializesInOpenState() external view {
        //assertEq(uint256(raffle.getRaffileState()),0);
        //or
        assert(raffle.getRaffileState() == Raffile.RaffileState.Open);

        //console.log(raffle.getRaffileState());
    }

    function testRaffileRevertWhenYouDontPayEnough() external {
        //check more about selector
        vm.expectRevert(Raffile.Raffile_SendMoreToEnterRaffile.selector);
        vm.prank(PLAYER);
        raffle.enterRaffile();
    }

    function testRaffileRecordPlayerWhenEnterRaffile() external {
        vm.prank(PLAYER);
        raffle.enterRaffile{value: enteranceFee}();

        assert(raffle.getPlayers(0) == PLAYER);
    }

    function testEnteringRaffileEmitsEvent() external {
        vm.prank(PLAYER);
        // the expectmit accept 5 prameters first 3 are true or false depend  if you have 3 indexed event,
        // the 4th is true of false if u have non indexed event , and the last the  the CA of the contracts

        vm.expectEmit(true, false, false, false, address(raffle));

        // the we emit the event we expec below it

        emit RaffileEntered(PLAYER);

        raffle.enterRaffile{value: enteranceFee}();
    }

    function testDontAllowToEnterRaffileWhilePickingWinner() external {
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
    function testcheckUpkeepReturnsTrue() external {
        vm.prank(PLAYER);

        raffle.enterRaffile{value: enteranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        (bool upkeep, ) = raffle.checkUpKeep("");

        assert(upkeep == true);
    }

    function testcheckUpkeepReturnsfalse() external {
        (bool upkeep, ) = raffle.checkUpKeep("");
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        assert(!upkeep);
    }

    function testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue() external {
        vm.prank(PLAYER);

        raffle.enterRaffile{value: enteranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        // we can leave it like this if it pass i wil work else it will fail
        raffle.performUpkeep();
    }

    function testPerformUpkeepRevertIfCheckUpkeepIsFalse() external {
        vm.prank(PLAYER);

        raffle.enterRaffile{value: enteranceFee}();

        uint256 balance = address(raffle).balance;

        uint256 numplayers = 1;
        //we use this abi stuff if our custom error accept param
        vm.expectRevert(
            abi.encodeWithSelector(
                Raffile.Raffile__UpkeepNotNeeded.selector,
                balance,
                numplayers
            )
        );

        raffle.performUpkeep();
    }

    modifier raffleEntered() {
        vm.prank(PLAYER);

        raffle.enterRaffile{value: enteranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    function testPerformUpKeepUpdateRaffleStateAndEmitRequestedId() external {
        vm.prank(PLAYER);

        raffle.enterRaffile{value: enteranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        //vm.recoardlogs = record  and stick them to an array what ever log of event that is been emitter below it

        vm.recordLogs();
        raffle.performUpkeep();

        //vm.getrecorded the the recored logs from vm.record,

        Vm.Log[] memory enteries = vm.getRecordedLogs();

        //go to the Vm.Log file for more info or ask ai

        //anything return from the getlogs will be in bytes32

        //to get our request id from the log

        //the first index are reserved for vrf so we start from 1
        bytes32 requestId = enteries[1].topics[1];
        //console.log(requestId);

        Raffile.RaffileState s_raffleState = raffle.getRaffileState();

        assert(uint256(requestId) > 0);
        assert(uint256(s_raffleState) == 1);
    }



// note our last two test here will fail in forke and or real envron cuase only 
//chainLink node can call the fn we are trying to call

//but will pass in local


//that why we create this to skipp em in real chain


modifier skipFork(){
    if(block.chainid != LOCAL_CHAIN_ID){
       return;
    }
 _;
}





    // fuzz test

    function testFulfillrandomWordsCanOnlyBeCalledAfterPerformUpkeep(
        uint256 requestId
    ) external skipFork raffleEntered {
        // remember perform upkeep call fullfill random words in thier code

        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);

        //the the full we want to make sure that not any time of input number will work

        // that why we use  fuzz test  to test different number  first pass it to param then to the fn
        VRFCoordinatorV2_5Mock(vrfCodination).fulfillRandomWords(
            requestId,
            address(raffle)
        );
    }

    function testfullfillRandomWordsWinnerSendMoney() external skipFork raffleEntered {
        uint256 additionalEntries = 3;
        uint256 startingIndex = 1;
        address expectedWinner = address(1);

        for (
            uint256 i = startingIndex;
            i < startingIndex + additionalEntries;
            i++
        ) {
            address newPlayer = address(uint160(i));
            hoax(newPlayer, 2 ether);

            raffle.enterRaffile{value:enteranceFee}();
        }





        uint256 startingTimeStamp = raffle.getLastTimeStamp();


//Act
vm.recordLogs();
raffle.performUpkeep();

Vm.Log[] memory enteries = vm.getRecordedLogs();
bytes32 requestId = enteries[1].topics[1];


 VRFCoordinatorV2_5Mock(vrfCodination).fulfillRandomWords(
          uint256( requestId),
            address(raffle));

//assert

address recentWinner = raffle.getRecentWinner();
uint256 raffleState = uint256(raffle.getRaffileState());
uint256 winnerbalance = recentWinner.balance;
uint256 endingTimeStamp = raffle.getLastTimeStamp();
uint256 prize = enteranceFee *(additionalEntries +1);




assert(raffleState == 0);
assert(recentWinner == expectedWinner);
assert(endingTimeStamp > startingTimeStamp);



    }
}
