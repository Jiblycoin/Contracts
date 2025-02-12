// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../core/JiblycoinCore.sol";
import "../libraries/DiamondStorageLib.sol";
import "../libraries/Errors.sol";
import "../libraries/JiblycoinLoyaltyLib.sol";

/**
 * @title JiblycoinLoyaltyRewards
 * @notice Provides loyalty rewards functionalities for Jiblycoin.
 * @dev Extends JiblycoinCore and uses centralized storage via DiamondStorageLib.
 *      Functions include claiming loyalty points and adding referral relationships.
 *      Detailed NatSpec documentation and custom error usage are provided for clarity and gas savings.
 */
abstract contract JiblycoinLoyaltyRewards is JiblycoinCore {
    using JiblycoinLoyaltyLib for uint256;

    /**
     * @notice Emitted when a user successfully claims loyalty points.
     * @param user The address of the user claiming points.
     * @param points The amount of loyalty points claimed.
     */
    event JiblyPointsClaimed(address indexed user, uint256 points);

    /**
     * @notice Emitted when referral loyalty points are distributed.
     * @param referrer The address receiving referral points.
     * @param referee The address that triggered the referral.
     * @param points The amount of referral points distributed.
     */
    event ReferralJiblyPointsAdded(address indexed referrer, address indexed referee, uint256 points);

    /**
     * @notice Initializes the loyalty rewards module.
     * @dev Sets the referral reward rates and caps.
     * @param _referralJiblyPointsRates An array of three referral reward rates (in basis points).
     * @param _referralJiblyPointsCap The maximum cap for referral points.
     * @param _userJiblyPointsCap The maximum points a user can claim.
     */
    function __JiblycoinLoyaltyRewards_init(
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
     * @dev Reverts with Errors.AlreadyClaimed if the user has already claimed their points.
     *      Reverts with an insufficient pool error if the contract balance is too low or if the user's cap would be exceeded.
     */
    function claimJiblyPoints() external whenNotPaused nonReentrant {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (ds.jiblyPointsClaimed[msg.sender]) revert Errors.AlreadyClaimed();
        // Calculate holding duration based on the last transfer time.
        uint64 holdingDuration = uint64(block.timestamp - ds.lastTransferTime[msg.sender]);
        // Calculate loyalty points based on the user's tier and holding duration.
        uint256 points = JiblycoinLoyaltyLib.calculatePoints(ds.userJiblyTiers[msg.sender], holdingDuration);
        // Ensure the contract holds enough tokens for the reward.
        if (balanceOf(address(this)) < points) revert Errors.InsufficientBalance();
        // Ensure the user's balance will not exceed their points cap.
        if (balanceOf(msg.sender) + points > ds.userJiblyPointsCap) revert Errors.PointsCapExceeded();
        ds.jiblyPointsClaimed[msg.sender] = true;
        _transfer(address(this), msg.sender, points);
        emit JiblyPointsClaimed(msg.sender, points);
    }

    /**
     * @notice Adds a referral relationship for the caller.
     * @dev Reverts with Errors.AlreadyClaimed if the caller already has a referrer,
     *      if the caller attempts to refer themselves, or if the referrer has no token balance.
     * @param referrer The address of the referrer.
     */
    function addReferral(address referrer) external whenNotPaused {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (ds.referrers[msg.sender] != address(0)) revert Errors.AlreadyClaimed();
        if (referrer == msg.sender) revert Errors.ZeroAddress(); // Using ZeroAddress error for self-referral check.
        if (balanceOf(referrer) == 0) revert Errors.InsufficientBalance();
        ds.referrers[msg.sender] = referrer;
        emit ReferralJiblyPointsAdded(referrer, msg.sender, 0);
    }

    /**
     * @notice Internal function to distribute referral loyalty points up to three referral levels.
     * @dev Iterates through up to 3 levels of referrals, calculating and transferring referral points.
     *      Reverts if the contract balance is insufficient for any referral payout.
     * @param amount The base amount used to calculate referral points.
     * @param user The address of the user whose referral chain will receive points.
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
