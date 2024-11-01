# 酒店预订智能合约

这是一个基于区块链技术的去中心化酒店预订系统智能合约。它允许用户预订房间、添加评价，同时也让酒店管理者能够管理房间并提取代币。

## 主要功能

1. **房间管理**
   - 添加不同类型的新房间（总统套房、豪华房、套房）
   - 设置房间可用性
   - 获取房间详情，包括价格、可用性和评价

2. **预订系统**
   - 按类型预订房间
   - 查看预订详情
   - 取消预订（新功能）

3. **评价系统**
   - 为房间添加评价
   - 查看每个房间的评价

4. **代币集成**
   - 使用ERC20代币进行支付
   - 提取代币（仅限管理者）

5. **管理者功能**
   - 添加房间
   - 设置房间可用性
   - 提取代币

## 新功能：取消预定

新增了允许客人取消预订的功能。具体流程如下：

1. 客人可以通过调用`cancelBooking`函数并提供房间ID来取消预订。
2. 系统会收取取消费用（例如，总预订费用的**10**%）。
3. 剩余金额将退还给客人。
4. 该房间重新变为可预订状态。
5. 系统会发出`BookingCancelled`事件。

## 合约函数

- `addRoom`：向酒店添加新房间
- `bookRoomByCategory`：预订特定类型的房间
- `cancelBooking`：取消现有预订
- `addReview`：为房间添加评价
- `getRoomDetails`：获取特定房间的详情
- `getBookingDetails`：获取预订详情
- `getAllRooms`：获取所有房间列表
- `setRoomAvailability`：设置房间可用性
- `withdrawTokens`：提取代币（仅限管理者）

## 测试

我重新添加了丰富的测试用例以确保合约功能正常。测试文件`test/Booking.t.sol`包括以下测试：

- 添加房间
- 预订房间
- 取消预订
- 添加评价
- 提取代币
- 边界情况和错误处理

运行测试，请使用以下命令：

`forge test`

## Makefile

为了方便脚本执行，编写了Makefile以简化常见的开发任务。可用命令如下：

- `make build`：编译合约
- `make test`：运行测试套件
- `make deploy`：部署合约到指定网络
- `make call`：调用合约函数（例如：`make call FUNCTION=addRoom ARGS='0 "500000000000000000"'`）
- `make view`：查看只读函数的结果（例如：`make view FUNCTION=getRoomDetails ARGS=0`）

使用Makefile时，请确保您的`.env`文件中设置了必要的环境变量（RPC URL、私钥、合约地址）。

## 设置和部署

1. 克隆代码库
2. 安装依赖：`forge install`
3. 设置`.env`文件，填入必要变量
4. 编译合约：`make build`
5. 运行测试：`make test`
6. 部署：`make deploy`


## 部署记录
```
make deploy
[⠊] Compiling...
No files changed, compilation skipped
Script ran successfully.

== Return ==
0: contract HotelToken 0x3FA512dB9e504242B2678f140d3D2273395233cb
1: contract HotelBooking 0x7dc10aFd55c34a96267758D4BA3180Cd5Ad3cF07

== Logs ==
  Deploying contracts with the account: 0x4c75667C4251Cc782f51E5077e996F72682B3043
  HotelToken deployed at: 0x3FA512dB9e504242B2678f140d3D2273395233cb
  HotelBooking deployed at: 0x7dc10aFd55c34a96267758D4BA3180Cd5Ad3cF07
  Initial rooms added
  Minted 1000000 tokens to deployer
  Minted 10000 tokens to HotelBooking contract
  Approved HotelBooking contract to spend tokens on behalf of deployer
  Deployment and initial setup completed
  HotelToken address: 0x3FA512dB9e504242B2678f140d3D2273395233cb
  HotelBooking address: 0x7dc10aFd55c34a96267758D4BA3180Cd5Ad3cF07

## Setting up 1 EVM.

==========================

Chain 2810

Estimated gas price: 0.202 gwei

Estimated total gas used for script: 3723922

Estimated amount required: 0.000752232244 ETH

==========================

Transactions saved to: /root/web3/solidity-solution/tintinland/morph-hotel/contract/broadcast/Deployer.s.sol/2810/run-latest.json

Sensitive values saved to: /root/web3/solidity-solution/tintinland/morph-hotel/contract/cache/Deployer.s.sol/2810/run-latest.json
```
