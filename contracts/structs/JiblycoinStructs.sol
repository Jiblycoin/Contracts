// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title JiblycoinStructs
 * @notice Contains all data structures used in the Jiblycoin ecosystem.
 * @dev This library defines core structs and enums for fee parameters, governance, vesting,
 *      loyalty tiers, user statistics, bridging, staking, and proposals.
 */
library JiblycoinStructs {
    /**
     * @notice Fee parameters used for calculating transaction fees.
     * @param baseFeePercentage Base fee percentage in basis points (e.g., 100 represents 1%).
     * @param redistributionFeePercentage Fee percentage allocated for redistribution (in basis points).
     * @param burnFeePercentage Fee percentage allocated for burning tokens (in basis points).
     * @param buybackFeePercentage Fee percentage allocated for buyback (in basis points).
     * @param jiblyHoodFeePercentage Fee percentage allocated to the JiblyHood rewards pool (in basis points).
     */
    struct FeeParameters {
        uint16 baseFeePercentage;
        uint16 redistributionFeePercentage;
        uint16 burnFeePercentage;
        uint16 buybackFeePercentage;
        uint16 jiblyHoodFeePercentage;
    }

    /**
     * @notice Governance parameters for managing proposals and voting.
     * @param quorumPercentage Percentage of total supply required for quorum (in basis points).
     * @param minHoldingDuration Minimum duration (in seconds) tokens must be held to participate in governance.
     * @param votingRewardPercentage Reward percentage for voting (in basis points).
     */
    struct GovernanceParameters {
        uint256 quorumPercentage;
        uint64 minHoldingDuration;
        uint16 votingRewardPercentage;
    }

    /**
     * @notice Defines reward caps for governance-related points.
     * @param userPointsCap Maximum points that a single user can earn.
     * @param totalPointsCap Maximum total points that can be distributed across all users.
     * @param monthlyPointsCap Maximum points that can be distributed in a month.
     */
    struct RewardCapsStruct {
        uint256 userPointsCap;
        uint256 totalPointsCap;
        uint256 monthlyPointsCap;
    }

    /**
     * @notice Parameters for vesting tokens over time.
     * @param totalVestedAmount Total amount of tokens vested.
     * @param vestingStartTimestamp Timestamp when vesting begins.
     * @param vestingDuration Duration (in seconds) over which tokens vest.
     * @param cliffDuration Duration (in seconds) of the cliff before vesting starts.
     */
    struct VestingParameters {
        uint256 totalVestedAmount;
        uint64 vestingStartTimestamp;
        uint64 vestingDuration;
        uint64 cliffDuration;
    }

    /**
     * @notice Enumerates the available loyalty tiers for Jiblycoin holders.
     */
    enum JiblyLoyaltyTier {
        BellPepper,
        Jalapeno,
        Cayenne,
        Habanero,
        GhostPepper,
        CarolinaReaper,
        DragonsBreath,
        CapsaicinCrystal,
        UltimateJibly
    }

    /**
     * @notice Stores user statistics for loyalty rewards.
     * @param points Total loyalty points accumulated by the user.
     * @param currentTier The current loyalty tier of the user.
     * @param lastActivityTimestamp Timestamp of the user's last activity.
     */
    struct UserStats {
        uint256 points;
        JiblyLoyaltyTier currentTier;
        uint256 lastActivityTimestamp;
    }

    /**
     * @notice Parameters for cross-chain bridging.
     * @param bridgeContract The address of the bridge contract.
     * @param l2ChainId The chain ID of the target Layer 2 network.
     */
    struct BridgeParameters {
        address bridgeContract;
        uint256 l2ChainId;
    }

    /**
     * @notice Defines a staking pool.
     * @param id Unique identifier for the staking pool.
     * @param name Descriptive name of the staking pool.
     * @param baseRewardRate The base reward rate for tokens staked in the pool.
     * @param exclusive Indicates whether the pool is exclusive (requires NFT ownership).
     * @param currentRewardRate The current reward rate after market adjustments.
     * @param totalStaked Total tokens staked in the pool.
     */
    struct StakingPool {
        uint256 id;
        string name;
        uint256 baseRewardRate;
        bool exclusive;
        uint256 currentRewardRate;
        uint256 totalStaked;
    }

    /**
     * @notice Represents a governance proposal.
     * @dev This struct is intended for storage only due to the inclusion of a mapping.
     * @param id Unique identifier for the proposal.
     * @param description Text describing the proposal.
     * @param category Category or type of the proposal.
     * @param proposer Address of the user who created the proposal.
     * @param voteCount Total voting power accumulated for the proposal.
     * @param startTime Timestamp when the proposal's voting period begins.
     * @param endTime Timestamp when the proposal's voting period ends.
     * @param executed Flag indicating whether the proposal has been executed.
     * @param voters Mapping tracking addresses that have voted on the proposal.
     */
    struct Proposal {
        uint64 id;
        string description;
        string category;
        address proposer;
        uint256 voteCount;
        uint256 startTime;
        uint256 endTime;
        bool executed;
        mapping(address => bool) voters;
    }
}
