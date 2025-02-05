// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../loyaltyrewards/JiblycoinLoyaltyRewards.sol";

/**
 * @title JiblycoinLoyaltyFacet
 * @dev Facet for loyalty rewards functionalities.
 */
contract JiblycoinLoyaltyFacet is JiblycoinLoyaltyRewards {
    function initLoyaltyFacet(
        uint256[3] memory _referralJiblyPointsRates,
        uint256 _referralJiblyPointsCap,
        uint256 _userJiblyPointsCap
    ) external initializer {
        __JiblycoinLoyaltyRewards_init(_referralJiblyPointsRates, _referralJiblyPointsCap, _userJiblyPointsCap);
    }
}
