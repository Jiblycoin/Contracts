// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../structs/JiblycoinStructs.sol";

library DiamondStorageLib {
    /// @dev The storage slot for DiamondStorage.
    bytes32 internal constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct DiamondStorage {
        // Admin Management
        address adminWallet;
        // Facet management
        mapping(bytes4 => address) facets;
        bytes4[] functionSelectors;
        // For staking purposes
        uint256[] poolIds;
        // Fee management
        JiblycoinStructs.FeeParameters feeParams;
        // Bridge management
        JiblycoinStructs.BridgeParameters bridgeParams;
        // Governance
        JiblycoinStructs.GovernanceParameters governanceParams;
        JiblycoinStructs.RewardCapsStruct govPointsCaps;
        mapping(uint64 => JiblycoinStructs.Proposal) proposals;
        uint64 proposalCount;
        // Roles
        bytes32 ADMIN_ROLE;
        bytes32 UPGRADER_ROLE;
        bytes32 SECURITY_ROLE;
        bytes32 BRIDGE_ROLE;
        mapping(bytes32 => mapping(address => bool)) roles;
        // Anti‑whale
        uint256 maxWalletSize;
        uint256 maxTransactionSize;
        // Market condition
        uint256 marketConditionFactor;
        // Oracle and NFT integration
        address jiblycoinOracle;
        address nftContractAddress;
        // Points (for loyalty rewards, etc.)
        uint256 snapshotId;
        // Burn and Buyback
        bool monthlyBurnBuybackAllowed;
        uint256 monthlyBurnThreshold;
        uint256 monthlyBuybackThreshold;
        uint256 lastMonthlyActionTimestamp;
        // Lock eligibility
        uint256 redistributionPool;
        mapping(address => uint256) lockedTokens;
        mapping(address => uint256) lockExpiry;
        mapping(address => JiblycoinStructs.VestingParameters) jiblyVesting;
        // Upgrade
        uint64 upgradeDelay;
        mapping(address => uint256) pendingUpgrades;
        // Burn
        uint256 maxBurnsPerCooldown;
        uint256 burnCooldown;
        mapping(address => uint256) lastBurnTimestamp;
        mapping(address => uint256) burnCount;
        // Loyalty Rewards
        uint256[3] referralJiblyPointsRates;
        uint256 referralJiblyPointsCap;
        uint256 userJiblyPointsCap;
        mapping(address => address) referrers;
        mapping(address => uint256) referralJiblyPoints;
        mapping(address => bool) jiblyPointsClaimed;
        mapping(address => JiblycoinStructs.JiblyLoyaltyTier) userJiblyTiers;
        // Staking
        mapping(uint256 => JiblycoinStructs.StakingPool) stakingPools;
        mapping(uint256 => mapping(address => uint256)) stakedAmounts;
        mapping(uint256 => mapping(address => uint256)) rewardDebt;
        mapping(address => mapping(uint256 => uint256)) lastRewardTimestamp;
        // Token Transfers (for tracking holding duration)
        mapping(address => uint256) lastTransferTime;
        // ERC20 balances and supply
        mapping(address => uint256) balances;
        uint256 totalSupply;
        uint256 totalBurned;
        uint256 totalBuyback;
        // Delegations for governance
        mapping(address => mapping(address => uint256)) delegations;
        // JiblyHood (mass rewards) pool – cycles rewards over time
        uint256 jiblyHoodPool;
    }

    /// @dev Returns the diamond storage.
    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        // slither-disable-next-line inline-assembly
        assembly {
            ds.slot := position
        }
    }

    /// @dev Checks if an account has a specific role.
    function hasRole(DiamondStorage storage ds, bytes32 role, address account) internal view returns (bool) {
        return ds.roles[role][account];
    }

    /// @dev Grants a role to an account.
    function grantRole(DiamondStorage storage ds, bytes32 role, address account) internal {
        ds.roles[role][account] = true;
    }

    /// @dev Revokes a role from an account.
    function revokeRole(DiamondStorage storage ds, bytes32 role, address account) internal {
        ds.roles[role][account] = false;
    }
}
