// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract WETH is ERC20 {
    event Deposit(address indexed account, uint256 amount);
    event Withdrawal(address indexed account, uint256 amount);

    constructor() ERC20("Wrapped Ether", "WETH") Ownable(_msgSender()) {}

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        _mint(_msgSender(), msg.value);
        emit Deposit(_msgSender(), msg.value);
    }

    function withdraw(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(_msgSender()) >= amount, "Insufficient balance");
        _burn(_msgSender(), amount);
        payable(_msgSender()).transfer(amount);
        emit Withdrawal_msgSender(), amount);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        require(amount <= balanceOf(_msgSender()), "Insufficient balance");
        return super.transfer(recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        require(amount <= balanceOf(sender), "Insufficient balance");
        return super.transferFrom(sender, recipient, amount);
    }

    receive() external payable {
        deposit();
    }
}
