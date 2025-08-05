// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract EcommerceWithRefund {
    address public seller;
    address public buyer;
    uint256 public price;
    bool public itemSold;
    bool public refunded;

    event ItemListed(uint256 price);
    event ItemPurchased(address buyer, uint256 amount);
    event RefundIssued(address buyer, uint256 amount);

    constructor() {
        seller = msg.sender;
        itemSold = false;
        refunded = false;
    }

    // Seller lists the item with a price
    function listItem(uint256 _price) external {
        require(msg.sender == seller, "Only seller can list the item");
        require(!itemSold, "Item already sold");
        price = _price;
        emit ItemListed(price);
    }

    // Buyer purchases the item by sending exact price in Ether
    function purchase() external payable {
        require(!itemSold, "Item already sold");
        require(msg.value == price, "Please send exact price");
        buyer = msg.sender;
        itemSold = true;
        emit ItemPurchased(buyer, msg.value);
    }

    // Seller refunds the buyer
    function refund() external {
        require(msg.sender == seller, "Only seller can issue refund");
        require(itemSold, "Item not sold yet");
        require(!refunded, "Refund already issued");
        
        refunded = true;
        itemSold = false;
        price = 0;

        payable(buyer).transfer(address(this).balance);
        emit RefundIssued(buyer, address(this).balance);
    }

    // Seller can withdraw funds if item sold and not refunded
    function withdraw() external {
        require(msg.sender == seller, "Only seller can withdraw");
        require(itemSold, "Item not sold");
        require(!refunded, "Refund issued, nothing to withdraw");

        uint256 balance = address(this).balance;
        payable(seller).transfer(balance);
    }
}
