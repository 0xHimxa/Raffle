//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


library NetConfig{

 struct NetWorkConfig{
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordination;
    bytes32 gaslane;
    uint32 callbackGasLimit;
    uint32 subscriptionId;

  }

}

