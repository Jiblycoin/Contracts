# CrossChainBridge Guide

This guide explains how cross‑chain transfers are implemented in Jiblycoin using the Allbridge protocol. The bridge functionality is handled by the **JiblycoinBridgeFacet**, which integrates with the Allbridge Core contract to facilitate transfers between blockchains.

## 1. Overview

- **Purpose**: Enable Jiblycoin tokens to be moved across different blockchain networks (e.g., from Binance Smart Chain to another supported chain) via Allbridge.
- **Integration**: Uses the `IAllbridgeCore` interface to interact with the Allbridge Core contract.
- **Access Control**: Only addresses with the `ADMIN_ROLE` can initiate cross‑chain transfers, ensuring controlled and secure bridging operations.
- **Event Logging**: Successful transfers emit a `CrossChainTransferInitiated` event, which provides a unique transfer identifier and details of the transfer.

## 2. How It Works

1. **Configuration**:
   - **Set Allbridge Core Contract**: An admin calls the `setAllbridgeCoreAddress(address _bridgeAddress)` function in the JiblycoinBridgeFacet to store the address of the Allbridge Core contract in diamond storage.
   - This step must be done before any cross‑chain transfers can be initiated.

2. **Initiating a Transfer**:
   - The admin calls `sendTokensCrossChain` with the following parameters:
     - **amount**: The number of Jiblycoin tokens to transfer. Must be greater than zero.
     - **destinationChainId**: The identifier of the destination blockchain.
     - **recipient**: The address on the destination chain that will receive the tokens.
     - **extraData**: Additional data required by the Allbridge protocol (e.g., routing or metadata).
   - **Payable Function**: The function is payable, meaning you must send the appropriate native token fee along with the call (if required by Allbridge).

3. **Processing**:
   - The function validates the inputs:
     - Reverts if the `amount` is zero or the `recipient` is the zero address.
   - It then calls `allbridgeCore.sendToChain{value: msg.value}(...)`, passing the necessary parameters and any native token fees.
   - A unique `transferId` is returned by the Allbridge Core contract, and the `CrossChainTransferInitiated` event is emitted with transfer details.

## 3. Code Example

Below is an example snippet demonstrating how an admin might initiate a cross‑chain transfer:

```solidity
// Assume the Allbridge Core address has been set previously via setAllbridgeCoreAddress.
uint256 amount = 1000 * 1e18; // Transfer 1,000 Jiblycoin tokens
uint256 destinationChainId = 56; // Example chain ID for BSC or another supported network
address recipient = 0xRecipientAddressHere;
bytes memory extraData = ""; // Optional extra data

// Initiate the cross-chain transfer
bytes32 transferId = jiblycoinBridgeFacet.sendTokensCrossChain{value: msg.value}(
    amount,
    destinationChainId,
    recipient,
    extraData
);

// The event CrossChainTransferInitiated will log the transferId, amount, destinationChainId, and recipient.
