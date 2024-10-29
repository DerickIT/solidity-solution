// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

contract Auction {
    // 状态变量
    address payable public beneficiary;      // 拍卖受益人
    uint public auctionEnd;                  // 拍卖结束时间
    address public highestBidder;            // 最高出价者
    uint public highestBid;                  // 最高出价
    mapping(address => uint) pendingReturns; // 待退回的出价金额
    bool public ended;                       // 拍卖是否结束
    
    // 拍卖机制相关变量
    uint public constant COOLING_PERIOD = 5 minutes;     // 冷却时间
    uint public constant CRITICAL_TIME = 5 minutes;      // 加权临界时间
    uint public constant EXTENSION_TIME = 5 minutes;     // 延长时间
    uint public constant WEIGHT_MULTIPLIER = 2;          // 加权倍数
    mapping(address => uint) public lastBidTime;         // 上次出价时间
    uint public reservePrice;                           // 最低起拍价
    uint public minBidIncrement;                        // 最小加价幅度
    
    // 记录相关变量
    uint public totalBids;                              // 总出价次数
    mapping(address => uint) public bidCounts;          // 每个地址的出价次数
    address[] public participants;                      // 参与者列表
    
    // 管理相关变量
    bool public paused;                                 // 暂停状态
    address public owner;                               // 合约所有者

    // 事件声明
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    event AuctionExtended(uint newEndTime);
    event WeightedBidPlaced(address bidder, uint originalAmount, uint weightedAmount);
    event BidWithdrawn(address bidder, uint amount);
    event AuctionPaused(address by);
    event AuctionResumed(address by);

    // 修饰器
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier notPaused() {
        require(!paused, "Auction is paused");
        _;
    }

    // 构造函数
    constructor(
        uint _biddingTime,
        address payable _beneficiary,
        uint _reservePrice,
        uint _minBidIncrement
    ) {
        owner = msg.sender;
        beneficiary = _beneficiary;
        auctionEnd = block.timestamp + _biddingTime;
        reservePrice = _reservePrice;
        minBidIncrement = _minBidIncrement;
    }

    // 竞价函数
    function bid() public payable notPaused {
        require(block.timestamp <= auctionEnd, "Auction ended");
        require(msg.value >= reservePrice, "Bid below reserve price");
        
        // 检查冷却期
        require(
            block.timestamp >= lastBidTime[msg.sender] + COOLING_PERIOD || 
            lastBidTime[msg.sender] == 0,
            "Bidding in cooling period"
        );

        // 计算加权出价
        uint weightedBid = msg.value;
        if (auctionEnd - block.timestamp <= CRITICAL_TIME) {
            weightedBid = msg.value * WEIGHT_MULTIPLIER;
            emit WeightedBidPlaced(msg.sender, msg.value, weightedBid);
        }

        require(weightedBid >= highestBid + minBidIncrement, "Bid increment too small");

        // 处理之前的最高出价退款
        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }

        // 更新竞价信息
        highestBidder = msg.sender;
        highestBid = msg.value;
        lastBidTime[msg.sender] = block.timestamp;

        // 更新参与者信息
        if (bidCounts[msg.sender] == 0) {
            participants.push(msg.sender);
        }
        bidCounts[msg.sender]++;

        // 拍卖延期机制
        if (auctionEnd - block.timestamp <= CRITICAL_TIME) {
            auctionEnd += EXTENSION_TIME;
            emit AuctionExtended(auctionEnd);
        }

        emit HighestBidIncreased(msg.sender, msg.value);
    }

    // 提现函数
    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
            emit BidWithdrawn(msg.sender, amount);
        }
        return true;
    }

    // 结束拍卖
    function endAuction() public {
        require(block.timestamp >= auctionEnd, "Auction not yet ended");
        require(!ended, "Auction already ended");
        
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        beneficiary.transfer(highestBid);
    }

    // 管理功能
    function pauseAuction() public onlyOwner {
        paused = true;
        emit AuctionPaused(msg.sender);
    }

    function resumeAuction() public onlyOwner {
        paused = false;
        emit AuctionResumed(msg.sender);
    }

    // 查询功能
    function getAuctionStatus() public view returns (
        uint currentPrice,
        uint timeRemaining,
        bool isEnded,
        bool isPaused,
        uint participantCount,
        bool isWeightedPeriod,
        uint currentWeightMultiplier
    ) {
        bool inWeightedPeriod = auctionEnd - block.timestamp <= CRITICAL_TIME;
        return (
            highestBid,
            block.timestamp >= auctionEnd ? 0 : auctionEnd - block.timestamp,
            ended,
            paused,
            participants.length,
            inWeightedPeriod,
            inWeightedPeriod ? WEIGHT_MULTIPLIER : 1
        );
    }

    function getParticipantCount() public view returns (uint) {
        return participants.length;
    }

    function getUserBidCount(address user) public view returns (uint) {
        return bidCounts[user];
    }

    function getTimeUntilEnd() public view returns (uint) {
        if (block.timestamp >= auctionEnd) return 0;
        return auctionEnd - block.timestamp;
    }

    function getCurrentBid() public view returns (uint) {
        return highestBid;
    }
}
