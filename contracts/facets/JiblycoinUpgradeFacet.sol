// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../core/JiblycoinCore.sol";

/**
 * @title JiblycoinUpgrade
 * @dev Manages the upgrade mechanism with delay and authorization.
 */
abstract contract JiblycoinUpgrade is JiblycoinCore {
    uint64 public upgradeDelay;
    mapping(address => uint256) public pendingUpgrades;

    // ========= Events =========
    event UpgradeProposed(address indexed newImplementation, uint256 executeAfter);
    event UpgradeExecuted(address indexed newImplementation);
    event UpgradeDelaySet(uint64 newUpgradeDelay);

    /**
     * @dev Initializes the upgrade mechanism with a specified delay.
     * @param _upgradeDelay The delay before an upgrade can be executed (in seconds).
     */
    function __JiblycoinUpgrade_init(uint64 _upgradeDelay) internal onlyInitializing {
        upgradeDelay = _upgradeDelay;
    }

    /**
     * @notice Proposes a new implementation contract for upgrade.
     * @param newImplementation The address of the new implementation contract.
     */
    function proposeUpgrade(address newImplementation) external onlyRole(ADMIN_ROLE) whenNotPaused {
        require(newImplementation != address(0), "Invalid implementation");
        require(pendingUpgrades[newImplementation] == 0, "Already proposed");
        pendingUpgrades[newImplementation] = block.timestamp + upgradeDelay;
        emit UpgradeProposed(newImplementation, pendingUpgrades[newImplementation]);
    }

    /**
     * @notice Executes a proposed upgrade after the delay has passed.
     * @param newImplementation The address of the new implementation contract.
     */
    function executeUpgrade(address newImplementation) external nonReentrant whenNotPaused {
        uint256 executeTime = pendingUpgrades[newImplementation];
        require(executeTime != 0, "Not proposed");
        require(block.timestamp >= executeTime, "Upgrade delay not passed");
        _authorizeUpgrade(newImplementation);
        _upgradeTo(newImplementation);
        delete pendingUpgrades[newImplementation];
        emit UpgradeExecuted(newImplementation);
    }

    /**
     * @notice Sets a new upgrade delay.
     * @param _newUpgradeDelay The new delay duration in seconds.
     */
    function setUpgradeDelay(uint64 _newUpgradeDelay) external onlyRole(ADMIN_ROLE) {
        upgradeDelay = _newUpgradeDelay;
        emit UpgradeDelaySet(_newUpgradeDelay);
    }

    // ============= Storage Gap for Upgrades =============
    uint256[50] private __gap;
}
