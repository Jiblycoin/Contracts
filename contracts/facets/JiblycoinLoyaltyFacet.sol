// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Use named import with the correct path
import { JiblycoinLoyaltyRewards } from "../loyaltyrewards/JiblycoinLoyaltyRewards.sol";

/**
 * @title JiblycoinLoyaltyFacet
 * @notice Facet providing loyalty rewards functionalities for Jiblycoin.
 * @dev Extends JiblycoinLoyaltyRewards and serves as the external interface for loyalty reward operations.
 *      This facet is designed to be used with the diamond pattern and uses centralized storage.
 *      Detailed NatSpec documentation is included to assist auditors and developers.
 */
contract JiblycoinLoyaltyFacet is JiblycoinLoyaltyRewards {

    /**
     * @notice Initializes the loyalty rewards facet.
     * @dev This initializer function configures referral reward rates and caps.
     *      It can be called only once due to the initializer modifier.
     * @param _referralJiblyPointsRates An array of three referral reward rates (in basis points).
     * @param _referralJiblyPointsCap The maximum referral reward cap.
     * @param _userJiblyPointsCap The maximum points cap that a user can claim.
     */
    function initLoyaltyFacet(
        uint256[3] memory _referralJiblyPointsRates,
        uint256 _referralJiblyPointsCap,
        uint256 _userJiblyPointsCap
    ) external initializer {
        __JiblycoinLoyaltyRewards_init(_referralJiblyPointsRates, _referralJiblyPointsCap, _userJiblyPointsCap);
    }
}
