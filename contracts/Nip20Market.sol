// contracts/Nip20Market.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Nip20Market is Ownable{
    
    struct Order {
        address seller;
        uint256 price;
        bytes32 ticker;
        bytes32 inscription;
        bytes32 txhash;
        bool isActive;
    }

    mapping(uint256 => Order) public orders;
    mapping(bytes32 => bool) public items;
    
    uint256 public nextOrderId;
    uint256 private _fee; // divided by 1000
    // Trusted verifiers
    mapping(address => bool) public trustedVerifiers;


    event OrderCreated(uint256 indexed orderId, address indexed seller, uint256 price, bytes32 ticker, bytes32 txhash);
    event OrderRemoved(uint256 indexed orderId);
    event OrderExecuted(uint256 indexed orderId, address indexed buyer);
    event NIP20TokenEvent_transfer(address from, address to, bytes32 ticker, bytes32 txhash);

    constructor(address initialOwner) Ownable(initialOwner) {}
    receive() payable external{}
    fallback() external{}

    function addTrustedVerifier(address verifier) external onlyOwner {
        trustedVerifiers[verifier] = true;
    }

    function removeTrustedVerifier(address verifier) external onlyOwner {
        trustedVerifiers[verifier] = false;
    }
    
    
    // id is the txhash of the mint operation
    // txhash is the tx hash of the transfer (from sender to the contract address)
    function createOrder(uint256 price, bytes32 ticker, bytes32 id, bytes32 txhash, bytes memory signature) external {
        require(!items[txhash], "the item has already been listed before");
        
        orders[nextOrderId] = Order(msg.sender, price, ticker, id, txhash, true);
        items[txhash] = true;
        
        require(trustedVerifiers[recoverSigner(keccak256(abi.encodePacked(msg.sender, address(this), txhash, ticker, id)), signature)], "Signature not from a trusted verifier");

        emit OrderCreated(nextOrderId, msg.sender, price, ticker, id);
        nextOrderId++;
    }
    
    function removeOrder(uint256 id) external {
        require(orders[id].isActive, "no active order of this id");
        require(orders[id].seller == msg.sender, "only the sender can cancel the order");
        orders[id].isActive = false;
        emit OrderRemoved(id);
        emit NIP20TokenEvent_transfer(address(this), msg.sender, orders[id].ticker, orders[id].inscription);
    }
    

    function executeOrder(uint256 orderId) external payable {
        Order storage order = orders[orderId];
        require(order.isActive, "Order is not active");
        require(msg.value >= order.price, "Insufficient payment");

        // Transfer payment and emit event
        (bool sent, bytes memory data) = order.seller.call{value: msg.value * (1000 - _fee) / 1000}("");
        require(sent, "Failed to send Ether");
        
        emit NIP20TokenEvent_transfer(address(this), msg.sender,  order.ticker, order.inscription);

        order.isActive = false;
        emit OrderExecuted(orderId, msg.sender);
    }
    
    function setMarketFee(uint256 fee) external onlyOwner {
        require(fee < 1000, 'fee cannot exceed 1000');
        _fee = fee;
    }
    
    function collectFee(uint256 amount) external onlyOwner {
        payable(msg.sender).transfer(amount);
    }
    
     function recoverSigner(bytes32 data, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        (r, s, v) = splitSignature(signature);
        
        bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", data));
        return ecrecover(prefixedHash, v, r, s);
    }

    function splitSignature(bytes memory sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
