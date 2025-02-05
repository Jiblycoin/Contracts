// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library JiblycoinStructs {
    struct FeeParameters {
        uint16 baseFeePercentage;            // e.g., 100 => 1%
        uint16 redistributionFeePercentage;  // e.g., 200 => 2%
        uint16 burnFeePercentage;            // e.g., 50 => 0.5%
        uint16 buybackFeePercentage;         // e.g., 100 => 1%
        uint16 jiblyHoodFeePercentage;       // e.g., 50 => 0.5% allocated to the mass rewards pool (JiblyHood)
    }

    struct GovernanceParameters {
        uint256 quorumPercentage;      // e.g., 500 => 5%
        uint64 minHoldingDuration;     // Minimum duration tokens must be held (in seconds)
        uint16 votingRewardPercentage; // e.g., 100 => 1%
    }

    struct RewardCapsStruct {
        uint256 userPointsCap;     
        uint256 totalPointsCap;    
        uint256 monthlyPointsCap;  
    }

    struct VestingParameters {
        uint256 totalVestedAmount;       
        uint64 vestingStartTimestamp;    
        uint64 vestingDuration;          
        uint64 cliffDuration;            
    }

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

    struct UserStats {
        uint256 points;               
        JiblyLoyaltyTier currentTier; 
        uint256 lastActivityTimestamp;
    }

    struct BridgeParameters {
        address bridgeContract;  
        uint256 l2ChainId;       
    }

    struct StakingPool {
        uint256 id;
        string name;
        uint256 baseRewardRate;     
        bool exclusive;
        uint256 currentRewardRate;  
        uint256 totalStaked;        
    }

    // Note: Since Proposal contains a mapping, it is only usable in storage.
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
