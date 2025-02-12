// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title IJiblycoinOracle
 * @notice Interface for the Jiblycoin Oracle contract.
 * @dev Exposes a function to retrieve the current market condition factor, which is used to adjust fee parameters and other mechanisms.
 */
interface IJiblycoinOracle {
    /**
     * @notice Retrieves the current market condition factor.
     * @return marketConditionFactor The current market condition factor.
     */
    function getMarketConditionFactor() external view returns (uint256 marketConditionFactor);
}
