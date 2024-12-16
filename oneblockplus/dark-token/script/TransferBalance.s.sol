// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/DRKToken.sol";

contract TransferBalanceScript {
    DRKToken public drkToken;

    constructor(address tokenAddress) {
        drkToken = DRKToken(tokenAddress);
    }

    function run() external {
        // Transfer tokens from wallet1 to wallet2
        address wallet1 = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        address wallet2 = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

        uint256 amountToTransfer = 50 * 10 ** 18; // Amount to transfer
        require(
            drkToken.balanceOf(wallet1) >= amountToTransfer,
            "Insufficient balance"
        );

        drkToken.transfer(wallet2, amountToTransfer); // Transfer tokens from wallet1 to wallet2
    }
}
