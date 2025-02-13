# Governance Mechanism

This document details the on-chain governance process for Jiblycoin, including proposal creation, voting, and execution.

## 1. Overview
- Governance is managed primarily through the **JiblycoinGovernanceFacet**.
- Token holders (with a minimum balance, e.g., ≥1 JIBLY) participate in voting on proposals.
- Voting power is directly proportional to the holder's JIBLY balance.

## 2. Proposal Lifecycle
1. **Proposal Creation**:
   - Call `createProposal(description, category, executionTime)` with a detailed description, category (e.g., "Fee Adjustment", "New Feature"), and a set execution time.
2. **Voting**:
   - Token holders cast votes during the voting period (from `startTime` to `endTime`).
   - Each vote increases the proposal’s `voteCount` by the voter's token balance.
3. **Execution**:
   - Once the voting period ends and if the proposal meets the quorum (e.g., 5% of total supply), it may be executed.
   - Execution triggers changes based on the proposal category (e.g., fee updates or deploying a new feature facet).

## 3. Delegation
- Token holders can delegate their voting power to another address.
- Delegations are stored in the centralized diamond storage and contribute to the delegate’s effective voting power.

## 4. Roles & Permissions
- **ADMIN_ROLE**: 
  - Authorized to create proposals, adjust governance parameters, and execute proposals in emergencies.
- **DEFAULT_ADMIN_ROLE**:
  - Initially held by the admin wallet; can later be reassigned to a multisig wallet for improved security.

## 5. Security Considerations
- **Timelocks**: Critical governance actions (especially those affecting upgrades) are subject to timelocks.
- **Quorum**: A minimum percentage of total supply must vote in order for a proposal to pass.
- **Delegation Safeguards**: Checks prevent self-delegation or delegation to invalid addresses.
