// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ConstantProductAMM is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable token0; // WETH
    IERC20 public immutable token1; // Other ERC20 token

    uint public reserve0;
    uint public reserve1;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _mint(address _to, uint _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function _update(uint _reserve0, uint _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function swap(address _tokenIn, uint _amountIn) external nonReentrant returns (uint amountOut) {
        require(
            _tokenIn == address(token0) || _tokenIn == address(token1),
            "Invalid token"
        );
        require(_amountIn > 0, "Amount in = 0");

        bool isToken0 = _tokenIn == address(token0);
        (IERC20 tokenIn, IERC20 tokenOut, uint reserveIn, uint reserveOut) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);

        tokenIn.safeTransferFrom(msg.sender, address(this), _amountIn);

        // 0.3% fee
        uint amountInWithFee = (_amountIn * 997) / 1000;
        amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee);

        tokenOut.safeTransfer(msg.sender, amountOut);

        _update(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );
    }

    function addLiquidity(uint _amount0, uint _amount1) external nonReentrant returns (uint shares) {
        token0.safeTransferFrom(msg.sender, address(this), _amount0);
        token1.safeTransferFrom(msg.sender, address(this), _amount1);

        uint balance0 = token0.balanceOf(address(this));
        uint balance1 = token1.balanceOf(address(this));

        uint d0 = balance0 - reserve0;
        uint d1 = balance1 - reserve1;

        if (totalSupply == 0) {
            shares = Math.sqrt(d0 * d1);
        } else {
            shares = Math.min(
                (d0 * totalSupply) / reserve0,
                (d1 * totalSupply) / reserve1
            );
        }

        require(shares > 0, "Shares = 0");
        _mint(msg.sender, shares);

        _update(balance0, balance1);
    }

    function removeLiquidity(uint _shares) external nonReentrant returns (uint amount0, uint amount1) {
        require(_shares > 0, "Shares = 0");
        require(_shares <= balanceOf[msg.sender], "Insufficient balance");

        uint balance0 = token0.balanceOf(address(this));
        uint balance1 = token1.balanceOf(address(this));

        amount0 = (_shares * balance0) / totalSupply;
        amount1 = (_shares * balance1) / totalSupply;

        require(amount0 > 0 && amount1 > 0, "Amount0 or Amount1 = 0");

        _burn(msg.sender, _shares);

        _update(balance0 - amount0, balance1 - amount1);

        token0.safeTransfer(msg.sender, amount0);
        token1.safeTransfer(msg.sender, amount1);
    }
}

library Math {
    function min(uint x, uint y) internal pure returns (uint) {
        return x <= y ? x : y;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
