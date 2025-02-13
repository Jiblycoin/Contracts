// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinUpgrade, AlreadyProposed, NotProposed } from "../upgrade/JiblycoinUpgrade.sol";
import { Errors } from "../libraries/Errors.sol";

/// @title JiblycoinUpgradeFacet
/// @notice Facet for managing contract upgrades for Jiblycoin.
/// @dev Extends JiblycoinUpgrade. This facet calls the initializer __jiblycoinUpgradeInit.
contract JiblycoinUpgradeFacet is JiblycoinUpgrade {
    /**
     * @notice Initializes the upgrade facet with a specified upgrade delay.
     * @dev This initializer must be called during the deployment process.
     * @param _upgradeDelay The delay (in seconds) required before an upgrade can be executed.
     */
    function initUpgradeFacet(uint64 _upgradeDelay) external initializer {
        __jiblycoinUpgradeInit(_upgradeDelay);
    }

    /**
     * @notice Proposes a new contract implementation for an upgrade.
     * @dev Reverts if the new implementation address is zero or already proposed.
     *      Only callable by an account with the ADMIN_ROLE.
     * @param newImplementation The address of the new implementation contract.
     */
    function proposeNewUpgrade(address newImplementation) external onlyRole(ADMIN_ROLE) whenNotPaused {
        if (newImplementation == address(0)) revert Errors.ZeroAddress();
        if (pendingUpgrades[newImplementation] != 0) revert AlreadyProposed();
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
        if (executeTime == 0) revert NotProposed();
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
