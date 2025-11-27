//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

//for anything u dont understand check chain link doc

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
/** *
 *
 */

//custom error

error Raffile_SendMoreToEnterRaffile();
error Raffile_TransferFaild();
error Raffile__NotOPen();
//contract lick the inherit contract and read through it
contract Raffile is VRFConsumerBaseV2Plus {

//type deleration

//enum allow us to create basic custom type
enum RaffileState {Open, //0

 Calculating // 1
  }


   
   
   
    //state variables
    address private s_recentWinner;
    uint16 private constant REQUEST_CONFARMATION = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private immutable I_enteranceFee;
    uint256 private immutable i_interval;
    uint256 private  s_lastTimeStamp;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    address[] public s_players;
    RaffileState private s_raffleState;

    /*Event*/

    //are usefull it help or tell the frontend that something has change in the bloching
    //the fronted listen to it
    //the reason we dont use storage var is because they are expensive
    event RaffileEntered(address indexed player);
    event WinerPicked(address indexed winner)

    // the contract we inherit from have contructor that accept so we need to pass it in
    //like this
    // we frist pass it to our own contructor then to it
    constructor(
        uint256 enteranceFee,
        uint256 _interval,
        address vrfCodinator,
        bytes32 gaslane,
        uint256 subid,
        uint32 callbackgaslim
    ) VRFConsumerBaseV2Plus(vrfCodinator) {
        I_enteranceFee = enteranceFee;
        i_interval = _interval;
        s_lastTimeStamp = block.timestamp;
        i_keyHash = gaslane;
        i_subscriptionId = subid;
        i_callbackGasLimit = callbackgaslim;
    }

    function enterRaffile() external payable {
        // check more about this two revert type plese this is knda expen thatn if
        //require(msg.value >= I_enteranceFee, SendMoreToEnterRaffile());

        if (msg.value < I_enteranceFee) {
            revert Raffile_SendMoreToEnterRaffile();
        }

        if(s_raffleState !=  RaffileState.Open){
            revert Raffile__NotOPen();
        }
        s_players.push(payable(msg.sender));
        emit RaffileEntered(msg.sender);
    }

    //get a random number
    //use random number to pick a winner







    function pickWinner() external {

       
        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert();
        }
        s_raffleState = RaffileState.Calculating;

        // this below is gotton from a library we imported

        //the other is a struct that accept those value we need to provide it
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                //keyhash is the max amount of gas we are willing to pay in we to bytes32
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFARMATION,
                //max gas limit we are willing to pay
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });

          uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }



/**
 * wen writing a fn always keep CEI: Chekcs, effect,interaction
 * checks eg require if at the top
 * then effect(internal contract state)
 * interaction (eternal contrac interaction )
 * like we write in below code
 */


function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {


// the oracale return array of numbers eg this long 6795465894930204588588493992939393993229

//so we % by eg 10 then we use the remender to pick a random winner

/** effect internal contract state */
uint256 indexOfWinner = randomWords[0] % s_players.length;
address payable recentWinner = s_players[indexOfWinner];
s_recentWinner = recentWinner;
emit WinerPicked(recentWinner);


/**Interaction (EXternal contract Interaction) */

(bool success,) = recentWinner.call{value:address(this).balance}("");

if(!success){
    revert Raffile_TransferFaild();
}

s_raffleState = RaffileState.Open;
s_players = new address[](0);
s_lastTimeStamp = block.timestamp;

    }

    function getEnteranceFee() public view returns (uint256) {
        return I_enteranceFee;
    }
}
