// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../interfaces/IJiblycoinOracle.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/Errors.sol";

contract JiblycoinOracle is IJiblycoinOracle, Ownable {
    // The market condition factor (e.g., 100 represents +1% adjustment).
    uint256 private marketConditionFactor;

    event MarketConditionFactorUpdated(uint256 newFactor);

    /**
     * @dev Sets the initial market condition factor.
     * The deployer becomes the owner automatically.
     * @param _initialFactor The starting market condition factor.
     */
    constructor(uint256 _initialFactor) Ownable(msg.sender) {
        marketConditionFactor = _initialFactor;
    }

    /**
     * @notice Returns the current market condition factor.
     * @return marketConditionFactor The current market condition factor.
     */
    function getMarketConditionFactor() external view override returns (uint256) {
        return marketConditionFactor;
    }

    /**
     * @notice Allows the owner to update the market condition factor.
     * @param newFactor The new market condition factor.
     */
    function updateMarketConditionFactor(uint256 newFactor) external onlyOwner {
        marketConditionFactor = newFactor;
        emit MarketConditionFactorUpdated(newFactor);
    }
}
