//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script,console} from 'forge-std/Script.sol';
import {Raffile} from 'src/Raffle.sol';
import {HelperConfig} from './HelperConfig.s.sol';
import {CreateSubscription,FundSubscription,AddCustomer} from './interaction.s.sol';
contract DeployRaffile is Script{
    function run()external   returns(Raffile,HelperConfig){
HelperConfig helperConfig = new HelperConfig();

//local -> deploy mocks,get local config
//sepolia -> get sepolia config
HelperConfig.NetWorkConfig memory config = helperConfig.getConfig();


if(config.subscriptionId == 0){
 CreateSubscription createSubscription = new CreateSubscription();
 (config.subscriptionId,config.vrfCoordination) = createSubscription.createSubscription(config.vrfCoordination,config.account);
console.log('created sub id',config.subscriptionId);

FundSubscription fundSubscription = new FundSubscription();
fundSubscription.fundSubscription(config.vrfCoordination, config.subscriptionId,config.link,config.account);

}







vm.startBroadcast(/*config.account*/);
Raffile raffile = new Raffile(
    config.entranceFee,
    config.interval,
    config.vrfCoordination,
    config.gaslane,
   config.subscriptionId,
    config.callbackGasLimit

);
vm.stopBroadcast();
AddCustomer  addCustomer = new AddCustomer();


// we dont need to broadcast cuz in our consumer we alread have it
addCustomer.addCustomer(address(raffile), config.vrfCoordination,config.subscriptionId);

return(raffile,helperConfig);
    } 


    function deployContract() external returns(Raffile,HelperConfig){




    }
}
