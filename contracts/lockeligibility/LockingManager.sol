// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinLockEligibility } from "./JiblycoinLockEligibility.sol";
import { DiamondStorageLib } from "../libraries/DiamondStorageLib.sol";

/**
 * @title LockingManager
 * @notice Provides administrative functions for managing token locking in the Jiblycoin ecosystem.
 * @dev Extends JiblycoinLockEligibility to allow initialization and management of the token lock mechanism.
 */
contract LockingManager is JiblycoinLockEligibility {
    /**
     * @notice Initializes the locking mechanism with a specified redistribution pool.
     * @dev Only callable by an account with the admin role.
     * @param _redistributionPool The initial redistribution pool amount.
     */
    function initializeLocking(uint256 _redistributionPool)
        external
        onlyRole(DiamondStorageLib.diamondStorage().adminRole)
    {
        initializeLockEligibilityModule(_redistributionPool);
    }
}
