// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Store {
    struct Item {
        uint256 id;
        string name;
        string thumbnail;
        uint256 price;
        address owner;
    }

    mapping(uint256 => Item) public items;
    uint256 public itemCount;

    event ItemAdded(uint256 indexed itemId, string name, string thumbnail, uint256 price, address owner);
    event ItemPurchased(uint256 indexed itemId, address indexed buyer, uint256 price, address previousOwner);

    function addItem(string memory _name, string memory _thumbnail, uint256 _price) external {
        itemCount++;
        items[itemCount] = Item(itemCount, _name, _thumbnail, _price, msg.sender);
        emit ItemAdded(itemCount, _name, _thumbnail, _price, msg.sender);
    }

    function getItem(uint256 _itemId) external view returns (
        uint256 id,
        string memory name,
        string memory thumbnail,
        uint256 price,
        address owner
    ) {
        require(_itemId > 0 && _itemId <= itemCount, "Invalid item ID");
        Item storage item = items[_itemId];
        return (item.id, item.name, item.thumbnail, item.price, item.owner);
    }

    function purchaseItem(uint256 _itemId) payable external {
        require(_itemId > 0 && _itemId <= itemCount, "Invalid item ID");
        Item storage item = items[_itemId];
        require(msg.value == item.price, "Incorrect payment amount");
        require(item.owner != msg.sender, "You cannot buy your own item");

        address previousOwner = item.owner;
        item.owner = msg.sender;

        payable(previousOwner).transfer(msg.value);

        emit ItemPurchased(_itemId, msg.sender, item.price, previousOwner);
    }
    

    function getAllItems() external view returns (Item[] memory) {
        Item[] memory allItems = new Item[](itemCount);
        for (uint256 i = 1; i <= itemCount; i++) {
            allItems[i - 1] = items[i];
        }
        return allItems;
    }
}