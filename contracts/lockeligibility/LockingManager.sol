// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./JiblycoinLockEligibility.sol";
import "../libraries/DiamondStorageLib.sol";
import "../libraries/Errors.sol";

/**
 * @title LockingManager
 * @notice Provides administrative functions for managing token locking in the Jiblycoin ecosystem.
 * @dev Extends JiblycoinLockEligibility to allow initialization and management of the token lock mechanism.
 *      Uses centralized storage via DiamondStorageLib and enforces role-based access control.
 */
contract LockingManager is JiblycoinLockEligibility {
    /**
     * @notice Initializes the locking mechanism with a specified redistribution pool.
     * @dev Only callable by an account with the ADMIN_ROLE.
     *      Sets the initial redistribution pool value for locked tokens.
     * @param _redistributionPool The initial redistribution pool amount.
     */
    function initializeLocking(uint256 _redistributionPool) external onlyRole(DiamondStorageLib.diamondStorage().ADMIN_ROLE) {
        __JiblycoinLockEligibility_init(_redistributionPool);
    }
}
