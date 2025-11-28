//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from 'forge-std/Script.sol';
import {Raffile} from 'src/Raffle.sol';
import {HelperConfig} from './HelperConfig.s.sol';
contract DeployRaffile is Script{
    function run()external   returns(Raffile,HelperConfig){
HelperConfig helperConfig = new HelperConfig();

//local -> deploy mocks,get local config
//sepolia -> get sepolia config
HelperConfig.NetWorkConfig memory config = helperConfig.getConfig();

vm.startBroadcast();
Raffile raffile = new Raffile(
    config.entranceFee,
    config.interval,
    config.vrfCoordination,
    config.gaslane,
    config.callbackGasLimit,
    config.subscriptionId
);
vm.stopBroadcast();
return(raffile,helperConfig);
    } 


    function deployContract() external returns(Raffile,HelperConfig){




    }
}
