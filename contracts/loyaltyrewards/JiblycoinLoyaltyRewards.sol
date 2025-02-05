// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinCore } from "../core/JiblycoinCore.sol";
import { JiblycoinLoyaltyLib } from "../libraries/JiblycoinLoyaltyLib.sol";
import { DiamondStorageLib } from "../libraries/DiamondStorageLib.sol";
import { JiblycoinUtils } from "../utils/JiblycoinUtils.sol";
import { Errors } from "../libraries/Errors.sol";

error AlreadyClaimed();
error InsufficientPool();

abstract contract JiblycoinLoyaltyRewards is JiblycoinCore {
    using JiblycoinUtils for uint256;

    event JiblyPointsClaimed(address indexed user, uint256 points);
    event ReferralJiblyPointsAdded(address indexed referrer, address indexed referee, uint256 points);

    function __JiblycoinLoyaltyRewards_init(
        uint256[3] memory _referralJiblyPointsRates,
        uint256 _referralJiblyPointsCap,
        uint256 _userJiblyPointsCap
    ) internal onlyInitializing {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        ds.referralJiblyPointsRates = _referralJiblyPointsRates;
        ds.referralJiblyPointsCap = _referralJiblyPointsCap;
        ds.userJiblyPointsCap = _userJiblyPointsCap;
    }

    function claimJiblyPoints() external whenNotPaused nonReentrant {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (ds.jiblyPointsClaimed[msg.sender]) revert AlreadyClaimed();
        uint64 holdingDuration = uint64(block.timestamp - ds.lastTransferTime[msg.sender]);
        uint256 points = JiblycoinLoyaltyLib.calculatePoints(ds.userJiblyTiers[msg.sender], holdingDuration);
        if (balanceOf(address(this)) < points) revert InsufficientPool();
        if (balanceOf(msg.sender) + points > ds.userJiblyPointsCap) revert InsufficientPool();
        ds.jiblyPointsClaimed[msg.sender] = true;
        _transfer(address(this), msg.sender, points);
        emit JiblyPointsClaimed(msg.sender, points);
    }

    function addReferral(address referrer) external whenNotPaused {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (ds.referrers[msg.sender] != address(0)) revert AlreadyClaimed();
        if (referrer == msg.sender) revert AlreadyClaimed();
        if (balanceOf(referrer) == 0) revert AlreadyClaimed();
        ds.referrers[msg.sender] = referrer;
        emit ReferralJiblyPointsAdded(referrer, msg.sender, 0);
    }

    function _distributeReferralJiblyPoints(uint256 amount, address user) internal {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        address currentReferrer = ds.referrers[user];
        for (uint8 i = 0; i < 3; i++) {
            if (currentReferrer == address(0)) break;
            uint256 points = (amount * ds.referralJiblyPointsRates[i]) / 10000;
            if (ds.referralJiblyPoints[currentReferrer] + points > ds.referralJiblyPointsCap) {
                points = ds.referralJiblyPointsCap - ds.referralJiblyPoints[currentReferrer];
            }
            if (points > 0) {
                if (balanceOf(address(this)) < points) revert InsufficientPool();
                _transfer(address(this), currentReferrer, points);
                ds.referralJiblyPoints[currentReferrer] += points;
                emit ReferralJiblyPointsAdded(currentReferrer, user, points);
            }
            currentReferrer = ds.referrers[currentReferrer];
        }
    }

    uint256[50] private __gap;
}
