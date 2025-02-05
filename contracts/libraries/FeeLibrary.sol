// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinStructs as JStructs } from "../structs/JiblycoinStructs.sol";

library FeeLibrary {
    function calculateTotalFee(
        JStructs.FeeParameters memory feeParams,
        uint256 amount,
        uint256 marketConditionFactor
    ) internal pure returns (uint256 totalFee) {
        uint16 adjustedBaseFee = feeParams.baseFeePercentage + uint16(marketConditionFactor);
        totalFee = (amount * adjustedBaseFee) / 10000;
        totalFee += (amount * feeParams.redistributionFeePercentage) / 10000;
        totalFee += (amount * feeParams.burnFeePercentage) / 10000;
        totalFee += (amount * feeParams.buybackFeePercentage) / 10000;
        totalFee += (amount * feeParams.jiblyHoodFeePercentage) / 10000;
    }
}
