// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
  OnChainReceipts
  - No imports
  - No constructor
  - One-time claimOwnership() for deployer to become owner
  - Issue receipts for transactions, store metadata, verify, revoke
  - Short, gas-conscious design
*/

contract OnChainReceipts {
    // Receipt structure
    struct Receipt {
        uint256 id;
        address issuer;    // who created the receipt (msg.sender)
        address payer;     // who paid / who the receipt is for
        address payee;     // who received
        uint256 amount;    // units (wei or any agreed token unit)
        string details;    // freeform memo / metadata (IPFS hash, note)
        uint256 timestamp; // block timestamp when issued
        bool revoked;      // whether the receipt was revoked
    }

    // Storage
    uint256 private _nextId = 1;
    mapping(uint256 => Receipt) private _receipts;
    mapping(address => uint256[]) private _issuedBy; // receipts created by issuer
    mapping(address => uint256[]) private _receivedBy; // receipts where payee is receiver

    // Ownership (no constructor)
    address public owner; // initially zero; deployer should call claimOwnership()

    // Events
    event ReceiptIssued(uint256 indexed id, address indexed issuer, address indexed payer, address payee, uint256 amount);
    event ReceiptRevoked(uint256 indexed id, address indexed revokedBy);
    event OwnershipClaimed(address indexed newOwner);

    // --------- Modifiers ----------
    modifier onlyOwner() {
        require(owner == msg.sender, "Not owner");
        _;
    }

    modifier exists(uint256 id) {
        require(_receipts[id].id != 0, "Receipt not found");
        _;
    }

    // --------- Ownership ----------
    function claimOwnership() external {
        require(owner == address(0), "Ownership already claimed");
        owner = msg.sender;
        emit OwnershipClaimed(msg.sender);
    }

    // --------- Receipt lifecycle ----------
    /// @notice Issue a receipt. Returns receipt id.
    /// @param payer The address who paid (can be same as msg.sender)
    /// @param payee The address who received funds/services
    /// @param amount The amount (semantic units agreed off-chain)
    /// @param details A short description or IPFS hash for invoice/metadata
    function issueReceipt(address payer, address payee, uint256 amount, string calldata details) external returns (uint256) {
        require(payer != address(0) && payee != address(0), "zero addr");
        uint256 id = _nextId++;
        Receipt memory r = Receipt({
            id: id,
            issuer: msg.sender,
            payer: payer,
            payee: payee,
            amount: amount,
            details: details,
            timestamp: block.timestamp,
            revoked: false
        });
        _receipts[id] = r;
        _issuedBy[msg.sender].push(id);
        _receivedBy[payee].push(id);

        emit ReceiptIssued(id, msg.sender, payer, payee, amount);
        return id;
    }

    /// @notice Revoke a receipt. Only the issuer or contract owner can revoke.
    function revokeReceipt(uint256 id) external exists(id) {
        Receipt storage r = _receipts[id];
        require(!r.revoked, "already revoked");
        require(msg.sender == r.issuer || msg.sender == owner, "not authorized");
        r.revoked = true;
        emit ReceiptRevoked(id, msg.sender);
    }

    // --------- Views / helpers ----------
    function getReceipt(uint256 id) external view exists(id) returns (
        uint256, address, address, address, uint256, string memory, uint256, bool
    ) {
        Receipt storage r = _receipts[id];
        return (r.id, r.issuer, r.payer, r.payee, r.amount, r.details, r.timestamp, r.revoked);
    }

    function receiptsIssuedBy(address issuer) external view returns (uint256[] memory) {
        return _issuedBy[issuer];
    }

    function receiptsReceivedBy(address payee) external view returns (uint256[] memory) {
        return _receivedBy[payee];
    }

    /// @notice Quick on-chain verification helper: returns true if receipt exists, not revoked, and matches payer/payee/amount
    function verifyReceipt(uint256 id, address payer, address payee, uint256 amount) external view exists(id) returns (bool) {
        Receipt storage r = _receipts[id];
        if (r.revoked) return false;
        if (r.payer != payer) return false;
        if (r.payee != payee) return false;
        if (r.amount != amount) return false;
        return true;
    }

    // --------- Administrative ----------
    /// @notice Owner may purge receipts (irreversible) in case of legal takedown or storage cleanup.
    function purgeReceipt(uint256 id) external onlyOwner exists(id) {
        delete _receipts[id];
        // Note: arrays _issuedBy and _receivedBy keep historical ids for gas reasons;
        // owner can maintain off-chain indexing if strict deletion of arrays needed.
    }
}
