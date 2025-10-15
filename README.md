# Transaction Receipt Smart Contract

This project implements a simple **Receipt Issuance Smart Contract** on the **Ethereum Test Network**.  
The contract automatically records receipts for transactions made on-chain.

---

## 🧾 Contract Details

- **Contract Name:** `ReceiptIssuer`
- **Network:** Flow Testnet (Remix Deployment)
- **Contract Address:** 0xd9145CCE52D386f254917e481eB44e9943F39138
- **Language:** Solidity  
- **Version:** ^0.8.0  
- **Imports / Constructors:** None  
- **Input Fields:** None

---

## 📜 Contract Overview

The `ReceiptIssuer` contract creates receipts whenever users send transactions to it.  
Each transaction generates a unique receipt ID, timestamp, and the sender’s address.  
All receipts are stored on-chain and can be read publicly.

---

## 🧠 Key Features

- Automatically records each transaction as a receipt  
- No external imports or constructors  
- Fully self-contained Solidity contract  
- Public access to view receipts by ID  
- Transparent and immutable on-chain data storage

---


## 🧩 Example Usage

- User sends a transaction to the contract.  
- The contract automatically records:
  - Sender Address  
  - Timestamp  
  - Sequential Receipt ID  
- Receipts can be queried anytime later.

---

## ⚙️ Tech Stack

- **Solidity** for smart contract development  
- **Remix IDE** for deployment and testing  
- **Flow Testnet** as the network  

---

## 🛡️ License

This project is released under the **MIT License**.  
Use freely with attribution.

---

## 💡 Author

**Deployed by:** Garvit Singh

---

> “Every transaction deserves a receipt — even on the blockchain.”
