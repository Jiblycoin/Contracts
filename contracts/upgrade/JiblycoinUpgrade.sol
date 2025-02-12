// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../core/JiblycoinCore.sol";
import "../libraries/Errors.sol";

/**
 * @title JiblycoinUpgrade
 * @notice Manages the upgrade mechanism for Jiblycoin using the UUPS proxy pattern.
 * @dev Extends JiblycoinCore. Defines an upgrade delay and a mapping for pending upgrades.
 *      Provides functions for proposing and executing upgrades, with detailed NatSpec documentation,
 *      custom error usage for gas savings, non‑reentrancy, and role‑based access control.
 */
abstract contract JiblycoinUpgrade is JiblycoinCore {
    /// @notice Upgrade delay (in seconds) required before an upgrade can be executed.
    uint64 public upgradeDelay;
    /// @notice Mapping from proposed new implementation addresses to the timestamp after which the upgrade can be executed.
    mapping(address => uint256) public pendingUpgrades;

    /**
     * @notice Emitted when a new upgrade is proposed.
     * @param newImplementation The address of the proposed new implementation.
     * @param executeAfter The timestamp after which the upgrade can be executed.
     */
    event UpgradeProposed(address indexed newImplementation, uint256 executeAfter);

    /**
     * @notice Emitted when an upgrade is executed.
     * @param newImplementation The address of the new implementation.
     */
    event UpgradeExecuted(address indexed newImplementation);

    /**
     * @notice Emitted when the upgrade delay is updated.
     * @param newUpgradeDelay The new upgrade delay in seconds.
     */
    event UpgradeDelaySet(uint64 newUpgradeDelay);

    /**
     * @notice Initializes the upgrade mechanism.
     * @dev Must be called during contract initialization.
     * @param _upgradeDelay The delay (in seconds) before an upgrade can be executed.
     */
    function __JiblycoinUpgrade_init(uint64 _upgradeDelay) internal onlyInitializing {
        upgradeDelay = _upgradeDelay;
    }

    /**
     * @notice Proposes a new implementation for upgrade.
     * @dev Reverts with Errors.ZeroAddress if the new implementation address is zero.
     *      Reverts if an upgrade for this implementation has already been proposed.
     *      Only callable by an account with the ADMIN_ROLE.
     * @param newImplementation The address of the proposed new implementation.
     */
    function proposeUpgrade(address newImplementation) external onlyRole(ADMIN_ROLE) whenNotPaused {
        if (newImplementation == address(0)) revert Errors.ZeroAddress();
        require(pendingUpgrades[newImplementation] == 0, "Already proposed");
        pendingUpgrades[newImplementation] = block.timestamp + upgradeDelay;
        emit UpgradeProposed(newImplementation, pendingUpgrades[newImplementation]);
    }

    /**
     * @notice Executes a previously proposed upgrade.
     * @dev Reverts if the upgrade delay has not passed or if the implementation was not proposed.
     *      Protected by non‑reentrancy and pausable modifiers.
     * @param newImplementation The address of the new implementation.
     */
    function executeUpgrade(address newImplementation) external nonReentrant whenNotPaused {
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
    function setUpgradeDelay(uint64 _newUpgradeDelay) external onlyRole(ADMIN_ROLE) {
        upgradeDelay = _newUpgradeDelay;
        emit UpgradeDelaySet(_newUpgradeDelay);
    }

    uint256[50] private __gap;
}
