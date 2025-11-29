//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, CodeConstant} from "./HelperConfig.s.sol";
import {LinkToken} from 'test/mocks/LinkToken.sol';
// this allow us to get most recent deploy from broadcast folder
import {DevOpsTools} from 'lib/foundry-devops/src/DevOpsTools.sol';
// inside the mock we can import this to use it to create a subscription id

import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract CreateSubscription is Script{
    function createSubscriptionUsingConfig() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        // we will need the vrf coordinatore address to be able to create sub id
        address vrfCoordinator = helperConfig.getConfig().vrfCoordination;
       address account = helperConfig.getConfig().account;
        (uint256 subid, ) = createSubscription(vrfCoordinator,account);
        return (subid, vrfCoordinator);
    }

    function createSubscription(
        address vrfCoordinator,
        address account
    ) public returns (uint256, address) {
        console.log("creating subscription on this chain id", block.chainid);
        vm.startBroadcast(/*account*/);
        uint256 subid = VRFCoordinatorV2_5Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        return ( subid, vrfCoordinator);
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
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        address linkToken = helperConfig.getConfig().link;
        address account = helperConfig.getConfig().account;
  fundSubscription(vrfCoordinator,subscriptionId,linkToken,account);
console.log('here is the subscription Id', subscriptionId);
         
}

function fundSubscription(address vrfCoordinator, uint256 subscriptionId,address linkToken,address account)public{
console.log('Funding subcribtionId',subscriptionId);
console.log('Using vrfCoordinatior', vrfCoordinator);
console.log('On ChainId', block.chainid);

if(block.chainid ==  LOCAL_CHAIN_ID){

vm.startBroadcast(/*account*/);

// now we call the cahinLink  mock fn that will help use fund the subcription in local
VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscriptionId,FUND_AMOUNT);


vm.stopBroadcast();

}else{
    //it will check the send link balance then sendlink from it
    console.log(LinkToken(linkToken).balanceOf(msg.sender),'checking bal');
   
    vm.startBroadcast(/*account*/);

    LinkToken(linkToken).transferAndCall(vrfCoordinator,FUND_AMOUNT,abi.encode(subscriptionId));
    vm.stopBroadcast();

}



}

function run() public {
fundSubscriptionConfig();
}


}




// here is add the cusomer id

contract AddCustomer is Script{
    function addCustomerUsingConfig(address mostRecentlyDeployed) public{
 HelperConfig helperConfig = new HelperConfig();
address vrfCoordinator = helperConfig.getConfig().vrfCoordination;
uint256 subscribtionId = helperConfig.getConfig().subscriptionId;

addCustomer(mostRecentlyDeployed,vrfCoordinator,subscribtionId);

    }

    function addCustomer(address contractToAddtoVrf,address vrfCoordinator, uint256 subscribtionId)public{
        console.log('Adding customer  contract', contractToAddtoVrf);
        console.log('to vrf cordinator',vrfCoordinator);
        console.log('On Chain Id', block.chainid);

        vm.startBroadcast();

        // here is just like we are cliking the btn on ther website to add
//this place add out address to the vrf contract
VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subscribtionId,  contractToAddtoVrf);

       
        vm.stopBroadcast();

    }


    function run()external{
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment('Raffile', block.chainid);
       addCustomerUsingConfig(mostRecentlyDeployed);
    }
}