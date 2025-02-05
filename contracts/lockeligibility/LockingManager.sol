// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinLockEligibility } from "./JiblycoinLockEligibility.sol";

contract LockingManager is JiblycoinLockEligibility {
    function initializeLocking(uint256 _redistributionPool) external onlyRole(ADMIN_ROLE) {
        __JiblycoinLockEligibility_init(_redistributionPool);
    }
}
