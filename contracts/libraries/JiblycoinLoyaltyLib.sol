// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinStructs as JStructs } from "../structs/JiblycoinStructs.sol";

library JiblycoinLoyaltyLib {
    error NoPointsAvailable();

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
