// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../upgrade/JiblycoinUpgrade.sol";
import "../libraries/Errors.sol";

/**
 * @title JiblycoinUpgradeFacet
 * @notice Facet for managing contract upgrades for Jiblycoin.
 * @dev Extends JiblycoinUpgrade and integrates:
 *      - Detailed NatSpec documentation
 *      - Custom error usage for gas savings (e.g., ExecTimeZero)
 *      - Non‑reentrant protection and pausable checks (inherited from core)
 *      - Role‑based access control (only ADMIN_ROLE can propose/execute upgrades)
 *      - Centralized storage via the diamond pattern
 */
contract JiblycoinUpgradeFacet is JiblycoinUpgrade {
    /**
     * @notice Initializes the upgrade facet with a specified upgrade delay.
     * @dev This initializer must be called during the deployment process.
     * @param _upgradeDelay The delay (in seconds) required before an upgrade can be executed.
     */
    function initUpgradeFacet(uint64 _upgradeDelay) external initializer {
        __JiblycoinUpgrade_init(_upgradeDelay);
    }

    /**
     * @notice Proposes a new contract implementation for an upgrade.
     * @dev Reverts if the new implementation address is zero or already proposed.
     *      Only callable by an account with the ADMIN_ROLE.
     * @param newImplementation The address of the new implementation contract.
     */
    function proposeNewUpgrade(address newImplementation) external onlyRole(ADMIN_ROLE) whenNotPaused {
        if (newImplementation == address(0)) revert Errors.ZeroAddress();
        require(pendingUpgrades[newImplementation] == 0, "Already proposed");
        pendingUpgrades[newImplementation] = block.timestamp + upgradeDelay;
        emit UpgradeProposed(newImplementation, pendingUpgrades[newImplementation]);
    }

    /**
     * @notice Executes a previously proposed upgrade.
     * @dev Reverts if the upgrade delay has not yet passed or if the implementation was not proposed.
     *      Only callable by an account with the ADMIN_ROLE.
     * @param newImplementation The address of the new implementation contract.
     */
    function executeProposedUpgrade(address newImplementation) external nonReentrant whenNotPaused {
        uint256 executeTime = pendingUpgrades[newImplementation];
        require(executeTime != 0, "Not proposed");
        if (block.timestamp < executeTime) revert Errors.ExecTimeZero();
        _authorizeUpgrade(newImplementation);
        _upgradeTo(newImplementation);
        delete pendingUpgrades[newImplementation];
        emit UpgradeExecuted(newImplementation);
    }

    /**
     * @notice Updates the upgrade delay for future upgrade proposals.
     * @dev Only callable by an account with the ADMIN_ROLE.
     * @param _newUpgradeDelay The new upgrade delay in seconds.
     */
    function updateUpgradeDelay(uint64 _newUpgradeDelay) external onlyRole(ADMIN_ROLE) {
        upgradeDelay = _newUpgradeDelay;
        emit UpgradeDelaySet(_newUpgradeDelay);
    }
}
