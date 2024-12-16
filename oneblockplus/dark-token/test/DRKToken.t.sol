// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/DRKToken.sol";

contract DRKTokenTest is Test {
    DRKToken public drkToken;
    address public wallet1 =
        address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address public wallet2 =
        address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

    function setUp() public {
        drkToken = new DRKToken(1000 * 10 ** 18); // 初始供应量为1000个代币
    }

    function testMintAndTransfer() public {
        // Mint tokens to the contract deployer (this contract)
        drkToken.mint(wallet1, 100 * 10 ** 18); // Mint 100 tokens to wallet1
        drkToken.mint(wallet2, 200 * 10 ** 18); // Mint 200 tokens to wallet2

        // Check balances after minting
        assertEq(
            drkToken.balanceOf(wallet1),
            100 * 10 ** 18,
            "Wallet1 should have minted balance"
        );
        assertEq(
            drkToken.balanceOf(wallet2),
            200 * 10 ** 18,
            "Wallet2 should have minted balance"
        );

        // Transfer tokens from wallet1 to wallet2
        uint256 amountToTransfer = 50 * 10 ** 18;

        // Ensure wallet1 has enough balance before transferring
        require(
            drkToken.balanceOf(wallet1) >= amountToTransfer,
            "Insufficient balance in wallet1"
        );

        drkToken.transfer(wallet2, amountToTransfer);

        // Check balances after transfer
        assertEq(
            drkToken.balanceOf(wallet1),
            (100 - amountToTransfer) * 10 ** 18,
            "Wallet1 should have reduced balance after transfer"
        );
        assertEq(
            drkToken.balanceOf(wallet2),
            (200 + amountToTransfer) * 10 ** 18,
            "Wallet2 should have increased balance after receiving transfer"
        );
    }
}
