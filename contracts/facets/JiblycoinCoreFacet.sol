// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import * as Core from "../core/JiblycoinCore.sol";

contract JiblycoinCoreFacet is Core.JiblycoinCore {
    /**
     * @notice Toggles the circuit breaker to enable or disable critical operations.
     * @dev Only callable by an account with the ADMIN_ROLE.
     * @param state The new state of the circuit breaker (true for active, false for inactive).
     */
    function toggleCircuitBreaker(bool state) external onlyRole(ADMIN_ROLE) {
        circuitBreakerActive = state;
    }

    /**
     * @notice Updates the anti‑whale limits.
     * @dev Only callable by an account with the ADMIN_ROLE.
     * @param _maxWalletSize The new maximum wallet size.
     * @param _maxTransactionSize The new maximum transaction size.
     */
    function updateAntiWhaleLimits(uint256 _maxWalletSize, uint256 _maxTransactionSize) external onlyRole(ADMIN_ROLE) {
        maxWalletSize = _maxWalletSize;
        maxTransactionSize = _maxTransactionSize;
    }

    /**
     * @notice Updates the market condition factor.
     * @dev Only callable by an account with the ADMIN_ROLE.
     * @param _marketConditionFactor The new market condition factor.
     */
    function updateMarketConditionFactor(uint256 _marketConditionFactor) external onlyRole(ADMIN_ROLE) {
        marketConditionFactor = _marketConditionFactor;
    }

    /**
     * @notice Updates the incentive pools for gas incentives and long‑term bonuses.
     * @dev Only callable by an account with the ADMIN_ROLE.
     * @param _gasIncentivePool The new value for the gas incentive pool.
     * @param _longTermBonusPool The new value for the long‑term bonus pool.
     */
    function updateIncentivePools(uint256 _gasIncentivePool, uint256 _longTermBonusPool) external onlyRole(ADMIN_ROLE) {
        gasIncentivePool = _gasIncentivePool;
        longTermBonusPool = _longTermBonusPool;
    }
}
