// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title JiblycoinOracle
 * @notice Provides the current market condition factor for dynamic fee adjustments in the Jiblycoin ecosystem.
 * @dev Implements the IJiblycoinOracle interface and uses Ownable for access control.
 *      The market condition factor can be updated by the contract owner.
 */
contract JiblycoinOracle is Ownable {
    /// @notice Market condition factor (e.g., 100 represents a +1% adjustment).
    uint256 private marketConditionFactor;

    /**
     * @notice Emitted when the market condition factor is updated.
     * @param newFactor The new market condition factor.
     */
    event MarketConditionFactorUpdated(uint256 newFactor);

    /**
     * @notice Initializes the oracle with a starting market condition factor.
     * @param _initialFactor The initial market condition factor.
     */
    constructor(uint256 _initialFactor) Ownable(msg.sender) {
        marketConditionFactor = _initialFactor;
    }

    /**
     * @notice Returns the current market condition factor.
     * @return The current market condition factor.
     */
    function getMarketConditionFactor() external view returns (uint256) {
        return marketConditionFactor;
    }

    /**
     * @notice Updates the market condition factor.
     * @dev Only callable by the contract owner.
     * @param newFactor The new market condition factor.
     */
    function updateMarketConditionFactor(uint256 newFactor) external onlyOwner {
        marketConditionFactor = newFactor;
        emit MarketConditionFactorUpdated(newFactor);
    }
}
