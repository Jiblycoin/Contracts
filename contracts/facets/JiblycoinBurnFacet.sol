// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../libraries/DiamondStorageLib.sol";
import "../libraries/Errors.sol";

/**
 * @title JiblycoinBurnFacet
 * @notice Provides burning functionalities for Jiblycoin with rate limiting.
 * @dev Uses centralized storage via DiamondStorageLib and custom errors from Errors.sol
 *      to ensure gas-efficient and secure token burning operations.
 */
contract JiblycoinBurnFacet {
    using DiamondStorageLib for DiamondStorageLib.DiamondStorage;

    /**
     * @notice Emitted when Jiblycoin tokens are burned.
     * @param from The address from which tokens were burned.
     * @param amount The amount of tokens burned.
     */
    event JiblyPointsBurned(address indexed from, uint256 indexed amount);

    /**
     * @notice Emitted when the burn facet is initialized.
     * @param maxBurnsPerCooldown The maximum number of burns allowed per cooldown period.
     * @param burnCooldown The cooldown duration (in seconds) between burn actions.
     */
    event BurnFacetInitialized(uint256 maxBurnsPerCooldown, uint256 burnCooldown);

    /**
     * @notice Initializes the burn facet with rate limiting parameters.
     * @dev Can only be called once. Only an account with the ADMIN_ROLE is authorized.
     * @param _maxBurnsPerCooldown The maximum number of burns allowed during each cooldown period.
     * @param _burnCooldown The cooldown period in seconds after which the burn count resets.
     */
    function initBurnFacet(uint256 _maxBurnsPerCooldown, uint256 _burnCooldown) external {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        require(ds.hasRole(ds.ADMIN_ROLE, msg.sender), "Not authorized");
        require(ds.maxBurnsPerCooldown == 0 && ds.burnCooldown == 0, "Already initialized");
        ds.maxBurnsPerCooldown = _maxBurnsPerCooldown;
        ds.burnCooldown = _burnCooldown;
        emit BurnFacetInitialized(_maxBurnsPerCooldown, _burnCooldown);
    }

    /**
     * @notice Burns a specified amount of Jiblycoin tokens from the caller's balance.
     * @dev Uses custom errors for gas savings:
     *      - Reverts with Errors.BurnZero if amount is zero.
     *      - Reverts with Errors.InsufficientBalance if the caller's balance is insufficient.
     *      - Reverts with Errors.RateLimitExceeded if the caller has exceeded the allowed burns during the cooldown.
     *      The burn count resets if the cooldown period has passed.
     * @param amount The amount of tokens to burn.
     */
    function burnJiblyPoints(uint256 amount) external {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (amount == 0) revert Errors.BurnZero();
        if (ds.balances[msg.sender] < amount) revert Errors.InsufficientBalance();

        // Reset burn count if the cooldown period has passed.
        if (block.timestamp >= ds.lastBurnTimestamp[msg.sender] + ds.burnCooldown) {
            ds.burnCount[msg.sender] = 0;
            ds.lastBurnTimestamp[msg.sender] = block.timestamp;
        }
        if (ds.burnCount[msg.sender] >= ds.maxBurnsPerCooldown) revert Errors.RateLimitExceeded();

        ds.balances[msg.sender] -= amount;
        ds.totalSupply -= amount;
        ds.totalBurned += amount;
        ds.burnCount[msg.sender] += 1;
        emit JiblyPointsBurned(msg.sender, amount);
    }
}
