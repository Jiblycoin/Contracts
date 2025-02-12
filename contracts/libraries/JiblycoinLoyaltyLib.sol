// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinStructs as JStructs } from "../structs/JiblycoinStructs.sol";

/**
 * @title JiblycoinLoyaltyLib
 * @notice Provides utility functions for calculating loyalty points based on user tier and holding duration.
 * @dev Contains one function to compute loyalty points and a custom error that is reverted when no points are available.
 */
library JiblycoinLoyaltyLib {
    /// @notice Thrown when the provided duration is insufficient to award any loyalty points for the specified tier.
    error NoPointsAvailable();

    /**
     * @notice Calculates loyalty points for a given loyalty tier and holding duration.
     * @dev Returns a predefined number of points (scaled to 18 decimals) if the duration criteria for the tier are met.
     *      Reverts with NoPointsAvailable() if the duration is insufficient.
     * @param tier The loyalty tier of the user.
     * @param duration The duration (in seconds) that tokens have been held.
     * @return points The calculated loyalty points.
     */
    function calculatePoints(JStructs.JiblyLoyaltyTier tier, uint64 duration) external pure returns (uint256 points) {
        if (tier == JStructs.JiblyLoyaltyTier.UltimateJibly && duration >= 5 * 365 days) {
            return 4500e18;
        }
        if (tier == JStructs.JiblyLoyaltyTier.CapsaicinCrystal && duration >= 4 * 365 days) {
            return 4000e18;
        }
        if (tier == JStructs.JiblyLoyaltyTier.DragonsBreath && duration >= 3 * 365 days) {
            return 3500e18;
        }
        if (tier == JStructs.JiblyLoyaltyTier.CarolinaReaper && duration >= 2 * 365 days) {
            return 3000e18;
        }
        if (tier == JStructs.JiblyLoyaltyTier.GhostPepper && duration >= 1 * 365 days) {
            return 2500e18;
        }
        if (tier == JStructs.JiblyLoyaltyTier.Habanero && duration >= 180 days) {
            return 2000e18;
        }
        if (tier == JStructs.JiblyLoyaltyTier.BellPepper && duration >= 90 days) {
            return 500e18;
        }
        revert NoPointsAvailable();
    }
}
