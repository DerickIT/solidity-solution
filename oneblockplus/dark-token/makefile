.PHONY: all build deploy test
include .env

all: build

build:
	forge build

deploy:
	forge create src/DRKToken.sol:DRKToken --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --constructor-args 1000000

test:
	forge test --match-path test/DRKToken.t.sol

mint-balance:
	@echo "Minting tokens..."
	forge script script/MintBalance.s.sol:MintBalanceScript --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --sig run(address) --args $(TOKEN_ADDRESS)



transfer-balance:
	@echo "Transferring tokens..."
	forge script script/TransferBalance.s.sol:TransferBalanceScript --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY)