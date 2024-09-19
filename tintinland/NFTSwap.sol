// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTSwap is ERC721Holder, ReentrancyGuard {
    struct Order {
        address owner;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Order)) public orders;

    event Listed(address indexed nftContract, uint256 indexed tokenId, address seller, uint256 price);
    event Revoked(address indexed nftContract, uint256 indexed tokenId);
    event Updated(address indexed nftContract, uint256 indexed tokenId, uint256 newPrice);
    event Purchased(address indexed nftContract, uint256 indexed tokenId, address buyer, uint256 price);

    function list(address _nftContract, uint256 _tokenId, uint256 _price) external {
        require(_price > 0, "Price must be greater than zero");
        require(orders[_nftContract][_tokenId].owner == address(0), "NFT already listed");

        IERC721 nft = IERC721(_nftContract);
        require(nft.ownerOf(_tokenId) == msg.sender, "Not the owner of the NFT");

        nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        orders[_nftContract][_tokenId] = Order(msg.sender, _price);

        emit Listed(_nftContract, _tokenId, msg.sender, _price);
    }

    function revoke(address _nftContract, uint256 _tokenId) external {
        Order memory order = orders[_nftContract][_tokenId];
        require(order.owner == msg.sender, "Not the owner of the order");

        IERC721(_nftContract).safeTransferFrom(address(this), msg.sender, _tokenId);

        delete orders[_nftContract][_tokenId];

        emit Revoked(_nftContract, _tokenId);
    }

    function update(address _nftContract, uint256 _tokenId, uint256 _newPrice) external {
        require(_newPrice > 0, "Price must be greater than zero");
        Order storage order = orders[_nftContract][_tokenId];
        require(order.owner == msg.sender, "Not the owner of the order");

        order.price = _newPrice;

        emit Updated(_nftContract, _tokenId, _newPrice);
    }

    function purchase(address _nftContract, uint256 _tokenId) external payable nonReentrant {
        Order memory order = orders[_nftContract][_tokenId];
        require(order.owner != address(0), "Order does not exist");
        require(msg.value >= order.price, "Insufficient payment");

        IERC721(_nftContract).safeTransferFrom(address(this), msg.sender, _tokenId);

        payable(order.owner).transfer(order.price);

        if (msg.value > order.price) {
            payable(msg.sender).transfer(msg.value - order.price);
        }

        delete orders[_nftContract][_tokenId];

        emit Purchased(_nftContract, _tokenId, msg.sender, order.price);
    }
}
