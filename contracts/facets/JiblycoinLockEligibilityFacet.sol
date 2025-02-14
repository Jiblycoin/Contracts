// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinLockEligibility } from "../lockeligibility/JiblycoinLockEligibility.sol";

/**
 * @title JiblycoinLockEligibilityFacet
 * @notice Facet that provides token locking and eligibility functionalities for Jiblycoin.
 * @dev Extends JiblycoinLockEligibility to allow users to lock tokens, unlock tokens,
 *      and initialize team vesting. This facet is intended for use with the diamond pattern,
 *      utilizing centralized storage.
 */
contract JiblycoinLockEligibilityFacet is JiblycoinLockEligibility {
    /**
     * @notice Initializes the lock eligibility facet.
     * @dev Sets the initial redistribution pool for locked tokens.
     *      This function is protected by the initializer modifier and can only be called once.
     * @param _redistributionPool The initial value for the redistribution pool.
     */
    function initLockEligibilityFacet(uint256 _redistributionPool) external initializer {
        initializeLockEligibilityModule(_redistributionPool);
    }
}
