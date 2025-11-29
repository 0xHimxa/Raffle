//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, CodeConstant} from "./HelperConfig.s.sol";
import {LinkToken} from 'test/mocks/LinkToken.sol';

// inside the mock we can import this to use it to create a subscription id

import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract CreateSubscription is Script{
    function createSubscriptionUsingConfig() public returns (uint32, address) {
        HelperConfig helperConfig = new HelperConfig();
        // we will need the vrf coordinatore address to be able to create sub id
        address vrfCoordinator = helperConfig.getConfig().vrfCoordination;
        (uint32 subid, ) = createSubscription(vrfCoordinator);
        return (subid, vrfCoordinator);
    }

    function createSubscription(
        address vrfCoordinator
    ) public returns (uint32, address) {
        console.log("creating subscription on this chain id", block.chainid);
        vm.startBroadcast();
        uint256 subid = VRFCoordinatorV2_5Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        return (uint32(subid), vrfCoordinator);
    }

    function run() external {
        createSubscriptionUsingConfig();
    }
}


contract FundSubscription is Script,CodeConstant {

uint256 public constant FUND_AMOUNT = 3 ether; // 3 Link

function fundSubscriptionConfig() public{


 HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordination;
        uint32 subscriptionId = helperConfig.getConfig().subscriptionId;
        address linkToken = helperConfig.getConfig().link;
  fundSubscription(vrfCoordinator,subscriptionId,linkToken);

         
}

function fundSubscription(address vrfCoordinator, uint32 subscriptionId,address linkToken)internal{
console.log('Funding subcribtionId',subscriptionId);
console.log('Using vrfCoordinatior', vrfCoordinator);
console.log('On ChainId', block.chainid);

if(block.chainid ==  LOCAL_CHAIN_ID){

vm.startBroadcast();

// now we call the cahinLink  mock fn that will help use fund the subcription in local
VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscriptionId,FUND_AMOUNT);


vm.stopBroadcast();

}else{
    vm.startBroadcast();
    LinkToken(linkToken).transferAndCall(vrfCoordinator,FUND_AMOUNT,abi.encode(subscriptionId));
    vm.stopBroadcast();

}



}

function run() public {
fundSubscriptionConfig();
}


}