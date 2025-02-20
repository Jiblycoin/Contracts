// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { DiamondStorageLib } from "../libraries/DiamondStorageLib.sol";
import { Errors } from "../libraries/Errors.sol";

// Define additional custom errors if not already defined in Errors.sol
error ReentrantCall();
error AlreadyPaused();
error NotPaused();
error NotAuthorized();

/// @title JiblycoinBurn
/// @notice Implements a burning mechanism with rate limiting.
/// @dev Uses centralized storage via DiamondStorageLib and custom errors.
///      Features:
///       - Non-reentrant protection via a custom modifier.
///       - Pausable functionality via pause/unpause functions.
///       - Only an admin (as defined in DiamondStorage) can pause/unpause.
///       - Rate limiting: each user can burn only a limited number of times per cooldown period.
contract JiblycoinBurn {
    using DiamondStorageLib for DiamondStorageLib.DiamondStorage;

    // ====================================================
    // Constants for Reentrancy Guard
    // ====================================================
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    // ====================================================
    // State Variables
    // ====================================================
    uint256 private _status;
    bool private _paused;

    // ====================================================
    // Events
    // ====================================================
    /// @notice Emitted when the contract is paused.
    event Paused(address account);

    /// @notice Emitted when the contract is unpaused.
    event Unpaused(address account);

    /// @notice Emitted when Jiblycoin points are burned.
    event JiblyPointsBurned(address indexed user, uint256 amount);

    // ====================================================
    // Constructor
    // ====================================================
    /// @notice Initializes the burn contract.
    /// @dev Sets the reentrancy status to not entered and the contract to unpaused.
    constructor() {
        _status = _NOT_ENTERED;
        _paused = false;
    }

    // ====================================================
    // Modifiers
    // ====================================================
    /// @notice Prevents reentrant calls.
    modifier nonReentrant() {
        if (_status == _ENTERED) revert ReentrantCall();
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    /// @notice Allows execution only when the contract is not paused.
    modifier whenNotPaused() {
        if (_paused) revert AlreadyPaused();
        _;
    }

    /// @notice Restricts function access to the admin wallet.
    /// @dev The admin wallet is retrieved from DiamondStorage.
    modifier onlyAdmin() {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (msg.sender != ds.adminWallet) revert NotAuthorized();
        _;
    }

    // ====================================================
    // Public Functions
    // ====================================================
    /// @notice Pauses the contract (only callable by admin).
    function pause() external onlyAdmin {
        if (_paused) revert AlreadyPaused();
        _paused = true;
        emit Paused(msg.sender);
    }

    /// @notice Unpauses the contract (only callable by admin).
    function unpause() external onlyAdmin {
        if (!_paused) revert NotPaused();
        _paused = false;
        emit Unpaused(msg.sender);
    }

    /// @notice Burns a specified amount of Jiblycoin tokens.
    /// @dev Applies non-reentrancy, pausing, and rate limiting.
    ///      Reverts if the burn amount is zero, if the caller’s balance is insufficient,
    ///      or if the rate limit is exceeded.
    /// @param amount The amount of tokens to burn.
    function burnJiblyPoints(uint256 amount) external whenNotPaused nonReentrant {
        if (amount == 0) revert Errors.BurnZero();
        
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (ds.balances[msg.sender] < amount) revert Errors.InsufficientBalance();

        // --- RATE LIMITING LOGIC ---
        // If the cooldown period has passed, reset the burn count.
        if (block.timestamp >= ds.lastBurnTimestamp[msg.sender] + ds.burnCooldown) {
            ds.burnCount[msg.sender] = 0;
            ds.lastBurnTimestamp[msg.sender] = block.timestamp;
        }
        // Check if the user has exceeded the maximum number of burns allowed.
        if (ds.burnCount[msg.sender] >= ds.maxBurnsPerCooldown) revert Errors.RateLimitExceeded();
        // Increment the burn count for the current cooldown period.
        ds.burnCount[msg.sender] += 1;
        // ---------------------------------

        // Burn the tokens.
        ds.balances[msg.sender] -= amount;
        ds.totalSupply -= amount;
        ds.totalBurned += amount;

        emit JiblyPointsBurned(msg.sender, amount);
    }
}
