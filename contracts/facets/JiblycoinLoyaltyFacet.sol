// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinLoyaltyRewards } from "../loyaltyrewards/JiblycoinLoyaltyRewards.sol";
import { DiamondStorageLib } from "../libraries/DiamondStorageLib.sol";
import { Errors } from "../libraries/Errors.sol";
import { JiblycoinLoyaltyLib } from "../libraries/JiblycoinLoyaltyLib.sol";
import { JiblycoinCore } from "../core/JiblycoinCore.sol";

/**
 * @title JiblycoinLoyaltyFacet
 * @notice Facet providing loyalty rewards functionalities for Jiblycoin.
 * @dev This updated version adds a minimum holding threshold for reward eligibility.
 */
contract JiblycoinLoyaltyFacet is JiblycoinLoyaltyRewards {
    // Define the minimum holding threshold: for a total supply of 10,000,000 tokens,
    // 0.01% equals 10,000,000 / 10000 = 1,000 tokens.
    uint256 public constant MINIMUM_HOLDING_THRESHOLD = JiblycoinCore.INITIAL_SUPPLY / 10000;

    /**
     * @notice Initializes the loyalty rewards facet.
     * @dev This initializer function configures referral reward rates and caps.
     * @param _referralJiblyPointsRates An array of three referral reward rates (in basis points).
     * @param _referralJiblyPointsCap The maximum referral reward cap.
     * @param _userJiblyPointsCap The maximum points a user can claim.
     */
    function initLoyaltyFacet(
        uint256[3] memory _referralJiblyPointsRates,
        uint256 _referralJiblyPointsCap,
        uint256 _userJiblyPointsCap
    ) external initializer {
        initJiblycoinLoyaltyRewards(_referralJiblyPointsRates, _referralJiblyPointsCap, _userJiblyPointsCap);
    }

    /**
     * @notice Allows a user to claim their loyalty points based on holding duration.
     * @dev This override adds a minimum holding threshold check.
     *      If the caller's balance is below the threshold, the claim will revert.
     *      Also, if the user sells tokens, the core _transfer function resets their progress.
     */
    function claimJiblyPoints() external whenNotPaused nonReentrant override {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (ds.jiblyPointsClaimed[msg.sender]) revert Errors.AlreadyClaimed();
        // New check: require that the user holds at least the minimum threshold.
        if (balanceOf(msg.sender) < MINIMUM_HOLDING_THRESHOLD) revert Errors.InsufficientBalance();

        uint64 holdingDuration = uint64(block.timestamp - ds.lastTransferTime[msg.sender]);
        uint256 points = JiblycoinLoyaltyLib.calculatePoints(ds.userJiblyTiers[msg.sender], holdingDuration);
        if (balanceOf(address(this)) < points) revert Errors.InsufficientBalance();
        if (balanceOf(msg.sender) + points > ds.userJiblyPointsCap) revert Errors.PointsCapExceeded();
        
        ds.jiblyPointsClaimed[msg.sender] = true;
        _transfer(address(this), msg.sender, points);
        emit JiblyPointsClaimed(msg.sender, points);
    }
}
