# Governance Mechanism

This document details the on‑chain governance of Jiblycoin, including proposals, voting power, and execution logic.

## 1. Overview
- Governance is primarily handled via the **JiblycoinGovernanceFacet**.
- Proposals can be created, voted on, and executed if they meet quorum.

## 2. Proposal Lifecycle
1. **Create Proposal**: Admin or any designated role calls `createProposal(description, category, executionTime)`.
2. **Voting**: Token holders with >= 1 JIBLY can vote. Voting period runs until `endTime`.
3. **Execution**: If `voteCount >= quorum`, proposal can be executed. Implementation depends on the category (Fee changes, new features, etc.).

## 3. Roles & Permissions
- **ADMIN_ROLE**: Has power to create proposals, set governance parameters, act as fallback for emergencies.
- **DEFAULT_ADMIN_ROLE**: Typically the same address as ADMIN_ROLE initially, can be reassigned to a multisig.

## 4. Quorum & Voting Power
- **Quorum**: By default, 5% of total supply must vote in favor.
- **Voting Power**: Equal to JIBLY balance. Future versions may factor in NFT holdings or staked amounts.

## 5. Delegation
- JIBLY holders can delegate their voting power to another address. Delegations are tracked in DiamondStorage.

## 6. Execution Examples
- **Fee Adjustment**: If the “Fee Adjustment” proposal passes, the contract updates `feeParams`.
- **New Feature**: Deploy a new facet and tie it to the diamond if the proposal is about adding new logic.

## 7. Security Considerations
- Time delays to protect from instant malicious proposals.
- Potential timelock on key changes, e.g., upgrades.

