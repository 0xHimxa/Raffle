//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from 'forge-std/Script.sol';
//we import our mock from chain link depende we have

import {VRFCoordinatorV2_5Mock} from '@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol';
import { LinkToken} from 'test/mocks/LinkToken.sol';

abstract contract CodeConstant {
    /** VRF Mock Values */
    uint96 public MOCK_BASE_FEE = 0.25 ether;
    uint96 public MOCK_GAS_PRICE_LINK = 1e9;
 //Link / Eth price
    int256  public MOCK_WEI_PER_UINT_LINK = 4e15;
   uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
   uint256 public constant LOCAL_CHAIN_ID = 31337;
}



contract HelperConfig is CodeConstant, Script{

error HelperConfig_InvalidChainId();


// the vrf is different for each network sepo diff from abtrum one
//  get it similar we do for aggv3 ussing chaing link site for vrf
//gaslane gotton from thier site as well 
 
  struct NetWorkConfig{
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordination;
    bytes32 gaslane;
    uint32 callbackGasLimit;
    uint32 subscriptionId;
    address link;

  }

  NetWorkConfig public localNetworkConfig;
 mapping (uint256 chainId => NetWorkConfig) networkConfigs;



 constructor(){
    networkConfigs[ETH_SEPOLIA_CHAIN_ID] =getSeopliaEthConfig();

 }



function getConfigBYChainId(uint256 chainId) public returns (NetWorkConfig memory){
 if(networkConfigs[chainId].vrfCoordination != address(0)){
    return networkConfigs[chainId];
 }
 else if(chainId == LOCAL_CHAIN_ID){
  return   getOrCreateAnvilEthConfig();

 }
 else{
    revert HelperConfig_InvalidChainId();
 }

}


function getConfig() public  returns(NetWorkConfig memory){
    return getConfigBYChainId(block.chainid);
}




 function getSeopliaEthConfig() public pure returns(NetWorkConfig memory){
    return  NetWorkConfig({
        entranceFee: 0.01 ether,// 1e16
        interval: 30, //30 seconds
        vrfCoordination: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
        gaslane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
callbackGasLimit: 50000,
//if we dont have a sub id our script will auto create one 
subscriptionId: 0,
//sepo link address so we can funding likr they do in da vid
link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
    });
 }



 function getOrCreateAnvilEthConfig() public returns(NetWorkConfig memory){

//check to see if we set an active network config

if(localNetworkConfig.vrfCoordination != address(0)){
    return localNetworkConfig;
}

vm.startBroadcast();
 VRFCoordinatorV2_5Mock vrfCoordinatorV2_5Mock = new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE,MOCK_GAS_PRICE_LINK,MOCK_WEI_PER_UINT_LINK);
// here we deploy our link token to anvil chain, for funding
LinkToken linktoken = new LinkToken();

vm.stopBroadcast();

localNetworkConfig = NetWorkConfig({
  entranceFee: 0.01 ether,// 1e16
        interval: 30, //30 seconds
        vrfCoordination: address(vrfCoordinatorV2_5Mock),
        //those not matter
        gaslane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
callbackGasLimit: 50000,
//if we dont have a sub id our script will auto create one 
subscriptionId: 0,
link: address(linktoken)



});
return localNetworkConfig;

 }


}