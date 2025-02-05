// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../lockeligibility/JiblycoinLockEligibility.sol";

/**
 * @title JiblycoinLockEligibilityFacet
 * @dev Facet for lock eligibility functionalities.
 */
contract JiblycoinLockEligibilityFacet is JiblycoinLockEligibility {
    function initLockEligibilityFacet(uint256 _redistributionPool) external initializer {
        __JiblycoinLockEligibility_init(_redistributionPool);
    }
}
