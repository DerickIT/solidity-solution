# 智能拍卖合约说明文档

## 功能实现概述

按照本期[dodo作业要求](https://www.notion.so/Bounty-08372a293256408c97db6a195c860757)，本智能合约实现了5，6，7作业要求，并增加功能形成一个相对完整的去中心化拍卖系统，包含以下核心功能：

### 1. 基础拍卖功能
- 竞标出价功能（bid函数）
- 资金退回机制（withdraw函数）
- 拍卖结束处理（endAuction函数）

### 2. 高级拍卖机制
- **时间加权机制**: 在拍卖结束前5分钟内，出价获得2倍权重加成
- **竞拍冷却机制**: 每个地址出价后需等待5分钟才能再次出价
- **拍卖延期机制**: 结束前5分钟内有新出价自动延长5分钟
- **最低起拍价机制**: 确保首次出价不低于保留价格
- **最小加价幅度**: 防止恶意的小额加价

### 3. 安全优化
- 紧急暂停功能（pauseAuction/resumeAuction）
- 安全的资金退回机制
- 状态检查和访问控制
- 防重入保护

## 合约使用说明

### 1. 部署合约
```solidity
constructor(
    uint _biddingTime,      // 拍卖持续时间（秒）
    address payable _beneficiary,  // 受益人地址
    uint _reservePrice,     // 最低起拍价
    uint _minBidIncrement   // 最小加价幅度
)
```

### 2. 主要功能调用

#### 参与竞拍
```solidity
function bid() public payable
```
- 调用时需附带ETH
- 出价必须高于当前最高价+最小加价幅度
- 首次出价需高于起拍价
- 需遵守冷却期限制

#### 提取资金
```solidity
function withdraw() public returns (bool)
```
- 被超价后可调用此函数提取之前的出价

#### 结束拍卖
```solidity
function endAuction() public
```
- 拍卖时间结束后可调用
- 自动将最高出价转给受益人

### 3. 查询功能

#### 获取拍卖状态
```solidity
function getAuctionStatus() public view returns (
    uint currentPrice,      // 当前最高价
    uint timeRemaining,     // 剩余时间
    bool isEnded,          // 是否结束
    bool isPaused,         // 是否暂停
    uint participantCount,  // 参与人数
    bool isWeightedPeriod, // 是否处于加权期
    uint currentWeightMultiplier  // 当前权重倍数
)
```

#### 其他查询功能
- `getParticipantCount()`: 获取参与者数量
- `getUserBidCount(address)`: 获取用户出价次数
- `getTimeUntilEnd()`: 获取剩余时间
- `getCurrentBid()`: 获取当前最高价

## 优化说明

1. **Gas优化**
- 使用mapping存储待退回金额
- 优化循环和状态变量访问
- 合理使用事件记录代替存储

2. **安全优化**
- 实现Checks-Effects-Interactions模式
- 添加重入保护
- 严格的状态检查

3. **可用性优化**
- 完善的事件通知机制
- 丰富的查询接口
- 灵活的管理功能

1. [合约地址](https://sepolia.etherscan.io/address/0xbd1eac0ad894fb6e78ff0c4272a1a02ab4f10cbb)
2. [交互地址](https://sepolia.etherscan.io/address/0xBd1eAC0ad894FB6e78FF0c4272a1a02Ab4f10cBB#writeContract)
