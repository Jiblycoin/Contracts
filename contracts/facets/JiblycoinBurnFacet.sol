// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../libraries/DiamondStorageLib.sol";
import "../libraries/Errors.sol";

/**
 * @title JiblycoinBurnFacet
 * @dev Facet for burning functionalities.
 */
contract JiblycoinBurnFacet {
    using DiamondStorageLib for DiamondStorageLib.DiamondStorage;

    event JiblyPointsBurned(address indexed from, uint256 indexed amount);
    event BurnFacetInitialized(uint256 maxBurnsPerCooldown, uint256 burnCooldown);

    function initBurnFacet(uint256 _maxBurnsPerCooldown, uint256 _burnCooldown) external {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        require(ds.hasRole(ds.ADMIN_ROLE, msg.sender), "Not authorized");
        require(ds.maxBurnsPerCooldown == 0 && ds.burnCooldown == 0, "Already initialized");
        ds.maxBurnsPerCooldown = _maxBurnsPerCooldown;
        ds.burnCooldown = _burnCooldown;
        emit BurnFacetInitialized(_maxBurnsPerCooldown, _burnCooldown);
    }

    function burnJiblyPoints(uint256 amount) external {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        require(amount > 0, Errors.BurnZero());
        require(ds.balances[msg.sender] >= amount, Errors.InsufficientBalance());
        if (block.timestamp >= ds.lastBurnTimestamp[msg.sender] + ds.burnCooldown) {
            ds.burnCount[msg.sender] = 0;
            ds.lastBurnTimestamp[msg.sender] = block.timestamp;
        }
        require(ds.burnCount[msg.sender] < ds.maxBurnsPerCooldown, Errors.RateLimitExceeded());
        ds.balances[msg.sender] -= amount;
        ds.totalSupply -= amount;
        ds.totalBurned += amount;
        ds.burnCount[msg.sender] += 1;
        emit JiblyPointsBurned(msg.sender, amount);
    }
}
