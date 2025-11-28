//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from 'forge-std/Test.sol';
import {DeployRaffile} from 'script/DeployRaffle.s.sol';
import {Raffile} from 'src/Raffle.sol';
import {HelperConfig} from 'script/HelperConfig.s.sol';



contract RaffileTest is  Test{
    Raffile raffle;
    HelperConfig helperConfig;

function setUp()external {
    DeployRaffile deployer =  new DeployRaffile();
    

}

}