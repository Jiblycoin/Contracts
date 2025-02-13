# Smart Contract Architecture

This document provides a detailed overview of Jiblycoin’s technical design using the diamond‑pattern architecture and explains the responsibilities of each facet.

## 1. Overview of the Diamond Pattern
- **Modularity & Upgradeability**: The diamond pattern segments functionality into multiple facets, each of which can be upgraded independently.
- **Centralized Storage**: All facets share a single state storage defined in `DiamondStorageLib.DiamondStorage`, ensuring a unified data model.
- **Function Routing**: The main proxy (JiblycoinDiamond.sol) delegates calls to the appropriate facet based on function selectors.

## 2. Key Contracts and Facets
1. **JiblycoinDiamond.sol**
   - The proxy contract that implements delegatecall-based routing.
2. **Core Facet (JiblycoinCoreFacet.sol)**
   - Manages token initialization, transfer logic, fee distribution, and updates to key parameters.
3. **Governance Facet (JiblycoinGovernanceFacet.sol)**
   - Handles proposal creation, voting, delegation, and execution of governance actions.
4. **Staking Facet (JiblycoinStakingFacet.sol)**
   - Implements multiple staking pools, calculates rewards, and supports both standard and exclusive (NFT gated) staking.
5. **Burn Facet (JiblycoinBurnFacet.sol)**
   - Provides rate-limited token burning with cooldown management.
6. **Loyalty Facet (JiblycoinLoyaltyFacet.sol)**
   - Manages loyalty rewards, referral programs, and bonus distributions.
7. **Lock Eligibility Facet (JiblycoinLockEligibilityFacet.sol)**
   - Allows token locking for vesting or enhanced eligibility for rewards.
8. **Bridge Facet (JiblycoinBridgeFacet.sol)**
   - Integrates with Allbridge to support cross-chain token transfers.
9. **Upgrade Facet (JiblycoinUpgradeFacet.sol)**
   - Coordinates upgrade proposals and execution using timelocks and role-based permissions.
10. **Diamond Loupe Facet (DiamondLoupeFacet.sol)**
    - Provides introspection methods as defined by EIP‑2535.

## 3. Integration of External Protocols
- **Chainlink VRF**: 
  - The core contract integrates Chainlink VRF to securely request randomness (e.g., for random rewards).
- **Allbridge**: 
  - Used for cross-chain transfers, allowing Jiblycoin to move tokens between blockchains.

## 4. Storage Layout & Security
- **DiamondStorageLib**: Centralizes state variables (including fees, roles, staking data, governance proposals, and more) to avoid storage collisions.
- **Security Measures**: Reentrancy guards, pausable functions, and strict role-based access control are implemented throughout the facets.
- **Upgradability**: Facets are designed to be replaced individually without redeploying the entire system.

## 5. Advantages & Tradeoffs
- **Advantages**:
  - High modularity, easier audits, and targeted upgrades.
  - Reduced per-facet contract size for better gas efficiency.
  - Flexibility to integrate new protocols (e.g., Chainlink VRF, Allbridge).
- **Tradeoffs**:
  - Increased architectural complexity.
  - Must manage storage layout carefully to avoid collisions.
  - Upgrades must be performed cautiously to maintain system security.
