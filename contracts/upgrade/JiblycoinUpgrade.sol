// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinCore } from "../core/JiblycoinCore.sol";
import { Errors } from "../libraries/Errors.sol";

/// @notice Thrown when an upgrade has already been proposed.
error AlreadyProposed();
/// @notice Thrown when an upgrade was not proposed.
error NotProposed();

/**
 * @title JiblycoinUpgrade
 * @notice Manages the upgrade mechanism for Jiblycoin using the UUPS proxy pattern.
 * @dev Extends JiblycoinCore. Defines an upgrade delay and a mapping for pending upgrades.
 *      Provides functions for proposing and executing upgrades, using custom errors for gas savings.
 */
abstract contract JiblycoinUpgrade is JiblycoinCore {
    /// @notice Upgrade delay (in seconds) required before an upgrade can be executed.
    uint64 public upgradeDelay;
    /// @notice Mapping from proposed new implementation addresses to the timestamp after which the upgrade can be executed.
    mapping(address => uint256) public pendingUpgrades;

    /// @notice Emitted when a new upgrade is proposed.
    /// @param newImplementation The address of the proposed new implementation.
    /// @param executeAfter The timestamp after which the upgrade can be executed.
    event UpgradeProposed(address indexed newImplementation, uint256 executeAfter);
    /// @notice Emitted when an upgrade is executed.
    /// @param newImplementation The address of the new implementation.
    event UpgradeExecuted(address indexed newImplementation);
    /// @notice Emitted when the upgrade delay is updated.
    /// @param newUpgradeDelay The new upgrade delay in seconds.
    event UpgradeDelaySet(uint64 newUpgradeDelay);

    /**
     * @notice Initializes the upgrade mechanism.
     * @dev Must be called during contract initialization.
     * @param _upgradeDelay The delay (in seconds) before an upgrade can be executed.
     */
    function __jiblycoinUpgradeInit(uint64 _upgradeDelay) internal onlyInitializing {
        upgradeDelay = _upgradeDelay;
    }

    /**
     * @notice Proposes a new implementation for upgrade.
     * @dev Reverts with Errors.ZeroAddress if the new implementation address is zero.
     *      Reverts with AlreadyProposed if an upgrade for this implementation has already been proposed.
     *      Only callable by an account with the ADMIN_ROLE.
     * @param newImplementation The address of the proposed new implementation.
     */
    function proposeUpgrade(address newImplementation) external onlyRole(ADMIN_ROLE) whenNotPaused {
        if (newImplementation == address(0)) revert Errors.ZeroAddress();
        if (pendingUpgrades[newImplementation] != 0) revert AlreadyProposed();
        pendingUpgrades[newImplementation] = block.timestamp + upgradeDelay;
        emit UpgradeProposed(newImplementation, pendingUpgrades[newImplementation]);
    }

    /**
     * @notice Executes a previously proposed upgrade.
     * @dev Reverts with NotProposed if the upgrade was not proposed.
     *      Reverts with Errors.ExecTimeZero if the upgrade delay has not passed.
     *      Protected by non‑reentrancy and pausable modifiers.
     * @param newImplementation The address of the new implementation.
     */
    function executeUpgrade(address newImplementation) external nonReentrant whenNotPaused {
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
    function setUpgradeDelay(uint64 _newUpgradeDelay) external onlyRole(ADMIN_ROLE) {
        upgradeDelay = _newUpgradeDelay;
        emit UpgradeDelaySet(_newUpgradeDelay);
    }

    uint256[50] private __gap;
}
