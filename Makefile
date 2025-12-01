-include .env

.PHONY: all test deploy build install

build:;forge build

test:;forge test

# install:
#  forge install cyfrin/foundry-devops@2.2 && 

#  forge install smartcontractkit/chainlink-brownie-contracts@1.1 && 

#  forge install foundry-rs/forge-std@v1.8.2 && 

#  forge install transmissions11/solmate@v6

deploy-sepo:;@forge script script/DeployRaffle.s.sol --rpc-url $(RPC_URL) --account sepo --broadcast -vvvv