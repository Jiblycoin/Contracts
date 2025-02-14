// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Import structs with a namespace alias to avoid global imports.
import { JiblycoinStructs as JStructs } from "../structs/JiblycoinStructs.sol";

/**
 * @title FeeLibrary
 * @notice Provides functionality to calculate transaction fees for Jiblycoin.
 * @dev Uses fee parameters defined in JStructs.FeeParameters and adjusts fees based on the market condition factor.
 *      This library ensures that fee calculations are efficient and gas-optimized.
 */
library FeeLibrary {
    /**
     * @notice Calculates the total fee for a given transaction amount.
     * @param feeParams The fee parameters struct containing individual fee percentages in basis points.
     * @param amount The transaction amount.
     * @param marketConditionFactor The market condition factor used to adjust the base fee.
     * @return totalFee The computed total fee.
     */
    function calculateTotalFee(
        JStructs.FeeParameters memory feeParams,
        uint256 amount,
        uint256 marketConditionFactor
    ) internal pure returns (uint256 totalFee) {
        // Adjust the base fee percentage with the market condition factor.
        uint16 adjustedBaseFee = feeParams.baseFeePercentage + uint16(marketConditionFactor);
        totalFee = (amount * adjustedBaseFee) / 10000;
        totalFee += (amount * feeParams.redistributionFeePercentage) / 10000;
        totalFee += (amount * feeParams.burnFeePercentage) / 10000;
        totalFee += (amount * feeParams.buybackFeePercentage) / 10000;
        totalFee += (amount * feeParams.jiblyHoodFeePercentage) / 10000;
    }
}
