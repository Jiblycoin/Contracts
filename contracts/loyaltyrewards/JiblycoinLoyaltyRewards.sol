// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinCore } from "../core/JiblycoinCore.sol";
import { DiamondStorageLib } from "../libraries/DiamondStorageLib.sol";
import { Errors } from "../libraries/Errors.sol";
import { JiblycoinLoyaltyLib } from "../libraries/JiblycoinLoyaltyLib.sol";

/**
 * @title JiblycoinLoyaltyRewards
 * @notice Provides loyalty rewards functionalities for Jiblycoin.
 * @dev Extends JiblycoinCore and uses centralized storage via DiamondStorageLib.
 *      Functions include claiming loyalty points (based on holding duration and tier) and managing referral relationships.
 */
abstract contract JiblycoinLoyaltyRewards is JiblycoinCore {
    using JiblycoinLoyaltyLib for uint256;

    /// @notice Emitted when a user successfully claims loyalty points.
    event JiblyPointsClaimed(address indexed user, uint256 points);
    /// @notice Emitted when referral loyalty points are distributed.
    event ReferralJiblyPointsAdded(address indexed referrer, address indexed referee, uint256 points);

    /**
     * @notice Initializes the loyalty rewards module.
     * @dev Sets the referral reward rates and cap parameters.
     * @param _referralJiblyPointsRates An array of three referral reward rates (in basis points).
     * @param _referralJiblyPointsCap The maximum cap for referral points.
     * @param _userJiblyPointsCap The maximum loyalty points a user can claim.
     */
    function initJiblycoinLoyaltyRewards(
        uint256[3] memory _referralJiblyPointsRates,
        uint256 _referralJiblyPointsCap,
        uint256 _userJiblyPointsCap
    ) internal onlyInitializing {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        ds.referralJiblyPointsRates = _referralJiblyPointsRates;
        ds.referralJiblyPointsCap = _referralJiblyPointsCap;
        ds.userJiblyPointsCap = _userJiblyPointsCap;
    }

    /**
     * @notice Allows a user to claim their loyalty points based on holding duration.
     * @dev Reverts with Errors.AlreadyClaimed if the user has already claimed points.
     *      Also reverts if the contract balance is insufficient or if the claim would exceed the user's cap.
     *      This function is virtual to allow further restrictions in derived contracts.
     */
    function claimJiblyPoints() external whenNotPaused nonReentrant virtual {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (ds.jiblyPointsClaimed[msg.sender]) revert Errors.AlreadyClaimed();

        // Calculate holding duration since the last token transfer.
        uint64 holdingDuration = uint64(block.timestamp - ds.lastTransferTime[msg.sender]);

        // Calculate loyalty points based on the user's tier and holding duration.
        uint256 points = JiblycoinLoyaltyLib.calculatePoints(ds.userJiblyTiers[msg.sender], holdingDuration);

        // Ensure the contract holds enough tokens and that the user's balance will not exceed the cap.
        if (balanceOf(address(this)) < points) revert Errors.InsufficientBalance();
        if (balanceOf(msg.sender) + points > ds.userJiblyPointsCap) revert Errors.PointsCapExceeded();

        ds.jiblyPointsClaimed[msg.sender] = true; // Mark as claimed so that subsequent claims are prevented.
        _transfer(address(this), msg.sender, points);
        emit JiblyPointsClaimed(msg.sender, points);
    }

    /**
     * @notice Adds a referral relationship for the caller.
     * @dev Reverts if the caller already has a referrer, if self-referral is attempted, or if the referrer has zero token balance.
     * @param referrer The address of the referrer.
     */
    function addReferral(address referrer) external whenNotPaused {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (ds.referrers[msg.sender] != address(0)) revert Errors.AlreadyClaimed();
        if (referrer == msg.sender) revert Errors.ZeroAddress(); // Self-referral is not allowed.
        if (balanceOf(referrer) == 0) revert Errors.InsufficientBalance();
        ds.referrers[msg.sender] = referrer;
        emit ReferralJiblyPointsAdded(referrer, msg.sender, 0);
    }

    /**
     * @notice Internal function to distribute referral loyalty points up to three referral levels.
     * @dev Iterates through up to three levels of referrals, calculating and transferring referral points.
     *      Reverts if the contract lacks sufficient tokens for any referral payout.
     * @param amount The base amount used to calculate referral points.
     * @param user The address whose referral chain will receive points.
     */
    function _distributeReferralJiblyPoints(uint256 amount, address user) internal {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        address currentReferrer = ds.referrers[user];
        for (uint8 i = 0; i < 3; i++) {
            if (currentReferrer == address(0)) break;
            uint256 points = (amount * ds.referralJiblyPointsRates[i]) / 10000;
            // Ensure the referral cap is not exceeded.
            if (ds.referralJiblyPoints[currentReferrer] + points > ds.referralJiblyPointsCap) {
                points = ds.referralJiblyPointsCap - ds.referralJiblyPoints[currentReferrer];
            }
            if (points > 0) {
                if (balanceOf(address(this)) < points) revert Errors.InsufficientBalance();
                _transfer(address(this), currentReferrer, points);
                ds.referralJiblyPoints[currentReferrer] += points;
                emit ReferralJiblyPointsAdded(currentReferrer, user, points);
            }
            currentReferrer = ds.referrers[currentReferrer];
        }
    }

    uint256[50] private __gap;
}
