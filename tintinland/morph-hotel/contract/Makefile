# Makefile for Solidity Smart Contract Development

# 环境变量
include .env
export $(shell sed 's/=.*//' .env)

# 默认网络 (可以在命令行中覆盖，例如 make deploy NETWORK=mainnet)
NETWORK ?= morph_holesky

# 合约相关变量
CONTRACT_NAME ?= HotelBooking
CONSTRUCTOR_ARGS ?= $(TOKEN_ADDRESS)

.PHONY: all clean build test deploy call

all: clean build test

# 清理构建文件
clean:
	@echo "Cleaning..."
	@forge clean

# 编译合约
build:
	@echo "Building..."
	@forge build

# 运行测试
test:
	@echo "Testing..."
	@forge test -vv

# 部署合约
deploy:
	@echo "Deploying to $(NETWORK)..."
	@forge script script/Deploy.s.sol:DeployerScript --rpc-url $(MORPH_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify


call:
	@echo "Calling $(FUNCTION) on $(CONTRACT_NAME)..."
	@cast send --rpc-url $(MORPH_RPC_URL) --private-key $(PRIVATE_KEY) \
		$(CONTRACT_ADDRESS) "$(FUNCTION)($(ARGS))"


view:
	@echo "Viewing $(FUNCTION) on $(CONTRACT_NAME)..."
	@cast call --rpc-url $(MORPH_RPC_URL) \
		$(CONTRACT_ADDRESS) "$(FUNCTION)($(ARGS))"