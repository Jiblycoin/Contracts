# Smart Contract Architecture

This document details the technical design of Jiblycoin’s diamond‑pattern architecture and how each facet contributes to the overall functionality.

---

## Overview of the Diamond Pattern
- **Why Diamond?** It allows modular design, easy upgrades, and a smaller per‑facet contract size.
- **Key Contracts**:
  1. **JiblycoinDiamond.sol** – The diamond’s main proxy.
  2. **Facets** – Each facet contains a cohesive set of functions:
     - **CoreFacet**: Core ERC20 token logic (transfer, balances, etc.)
     - **GovernanceFacet**: Proposal creation, voting, execution
     - **StakingFacet**: Staking pools, claiming rewards
     - **BurnFacet**: Burn logic with cooldown
     - **LoyaltyFacet**: Referral and loyalty points
     - **LockEligibilityFacet**: Locking / vesting
     - **BridgeFacet**: Allbridge integration for cross-chain
     - **UpgradeFacet**: Timelocked upgrade mechanics
     - **DiamondLoupeFacet**: EIP‑2535 “loupe” introspection
- **Storage Layout**:
  - All storage is centralized in `DiamondStorageLib.DiamondStorage`, so facets share state.

## Facet Responsibilities
1. **JiblycoinCoreFacet**  
   - General token initialization, bridging config, updates to governance parameters.
2. **JiblycoinGovernanceFacet**  
   - Adds proposals, voting, and tracks results.  
3. **JiblycoinStakingFacet**  
   - Allows users to stake tokens, calculates rewards, manages multiple staking pools.  
4. **JiblycoinBurnFacet**  
   - Implements rate-limited burning for Jibly tokens.  
5. **JiblycoinLoyaltyFacet**  
   - Loyalty points, referral logic, monthly buyback/burn triggers.  
6. **JiblycoinLockEligibilityFacet**  
   - Lock tokens for vesting or extra eligibility in events (optional).  
7. **JiblycoinBridgeFacet**  
   - Cross-chain transfer logic via Allbridge.  
8. **JiblycoinUpgradeFacet**  
   - Coordinates upgrades using UUPS pattern with timelocked proposals.  

## Contracts Folder Structure
Jiblycoin/
├── contracts/
│   ├── burn/
│   │   └── JiblycoinBurn.sol
│   ├── core/
│   │   └── JiblycoinCore.sol
│   ├── diamond/
│   │   └── JiblycoinDiamond.sol
│   ├── facets/
│   │   ├── DiamondLoupeFacet.sol
│   │   ├── JiblycoinCoreFacet.sol
│   │   ├── JiblycoinGovernanceFacet.sol
│   │   ├── JiblycoinLoyaltyFacet.sol
│   │   ├── JiblycoinStakingFacet.sol
│   │   ├── JiblycoinLockEligibilityFacet.sol
│   │   ├── JiblycoinUpgradeFacet.sol
│   │   ├── JiblycoinBurnFacet.sol
│   │   └── JiblycoinBridgeFacet.sol
│   ├── governance/
│   │   ├── JiblycoinGovernance.sol
│   │   └── GovernanceManager.sol
│   ├── interfaces/
│   │   ├── IJiblycoin.sol
│   │   ├── IJiblycoinNFT.sol
│   │   ├── IJiblycoinOracle.sol
│   │   └── IAllbridgeCore.sol
│   ├── libraries/
│   │   ├── DiamondStorageLib.sol
│   │   ├── Errors.sol
│   │   ├── FeeLibrary.sol
│   │   ├── JiblycoinLibraries.sol
│   │   ├── VotingLib.sol
│   │   └── JiblycoinLoyaltyLib.sol
│   ├── lockeligibility/
│   │   ├── JiblycoinLockEligibility.sol
│   │   └── LockingManager.sol
│   ├── loyaltyrewards/
│   │   └── JiblycoinLoyaltyRewards.sol
│   ├── nft/
│   │   └── JiblycoinNFT.sol
│   ├── oracle/
│   │   └── JiblycoinOracle.sol
│   ├── staking/
│   │   ├── JiblycoinStaking.sol
│   │   └── StakingManager.sol
│   ├── structs/
│   │   └── JiblycoinStructs.sol
│   ├── upgrade/
│   │   └── JiblycoinUpgrade.sol
│   └── utils/
│       └── JiblycoinUtils.sol
├── scripts/
│   └── deploy.js
├── tests/
│   └── DummyOracle.sol
│   └── Jiblycoin.Smoke.test.js
│   └── Lock.js
├── README.md
├── LICENSE
└── docs/
    ├── SmartContractArchitecture.md
    ├── GovernanceMechanism.md
    ├── TokenomicsOverview.md
    ├── StakingGuide.md
    ├── NFTIntegration.md

## Upgradability Flow
1. **Propose Upgrade**: Admin calls `proposeUpgrade(newImplementation)`.
2. **Wait Timelock**: Must wait for `upgradeDelay` seconds.
3. **Execute Upgrade**: Calls `executeUpgrade(newImplementation)`, triggers `_authorizeUpgrade` checks, finalizes upgrade.

## Advantages & Tradeoffs
- **Advantages**:
  - Modular, maintainable
  - Smaller facet contract size, easier to audit individually
  - Upgrades possible without redeploying entire system
- **Tradeoffs**:
  - Complexity of diamond routing
  - Must carefully manage storage collisions in DiamondStorage
  - Must carefully handle upgrades to prevent malicious code injection

