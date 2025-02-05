// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../core/JiblycoinCore.sol";

// Custom errors
error InvalidImplementation();
error UpgradeDelayNotPassed();

/**
 * @title JiblycoinUpgrade
 * @dev Manages upgrade mechanisms using UUPS proxy pattern.
 */
abstract contract JiblycoinUpgrade is JiblycoinCore {
    uint64 public upgradeDelay;
    mapping(address => uint256) public pendingUpgrades;

    event UpgradeProposed(address indexed newImplementation, uint256 executeAfter);
    event UpgradeExecuted(address indexed newImplementation);
    event UpgradeDelaySet(uint64 newUpgradeDelay);

    function __JiblycoinUpgrade_init(uint64 _upgradeDelay) internal onlyInitializing {
        upgradeDelay = _upgradeDelay;
    }

    function proposeUpgrade(address newImplementation) external onlyRole(ADMIN_ROLE) whenNotPaused {
        if (newImplementation == address(0)) revert InvalidImplementation();
        require(pendingUpgrades[newImplementation] == 0, "Already proposed");
        pendingUpgrades[newImplementation] = block.timestamp + upgradeDelay;
        emit UpgradeProposed(newImplementation, pendingUpgrades[newImplementation]);
    }

    function executeUpgrade(address newImplementation) external nonReentrant whenNotPaused {
        uint256 executeTime = pendingUpgrades[newImplementation];
        require(executeTime != 0, "Not proposed");
        if (block.timestamp < executeTime) revert UpgradeDelayNotPassed();
        _authorizeUpgrade(newImplementation);
        _upgradeTo(newImplementation);
        delete pendingUpgrades[newImplementation];
        emit UpgradeExecuted(newImplementation);
    }

    function setUpgradeDelay(uint64 _newUpgradeDelay) external onlyRole(ADMIN_ROLE) {
        upgradeDelay = _newUpgradeDelay;
        emit UpgradeDelaySet(_newUpgradeDelay);
    }

    uint256[50] private __gap;
}
