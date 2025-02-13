// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { DiamondStorageLib } from "../libraries/DiamondStorageLib.sol";
import { Errors } from "../libraries/Errors.sol";

// Define custom errors that were missing in Errors library
error ReentrantCall();
error AlreadyPaused();
error NotPaused();
error NotAuthorized();

/**
 * @title JiblycoinBurn
 * @notice Implements a burning mechanism with rate limiting.
 * @dev Uses centralized storage via DiamondStorageLib and custom errors.
 *
 * Detailed Features:
 * - Non-reentrant protection is applied via a custom modifier.
 * - Pausable functionality is included with pause/unpause functions.
 * - Only an admin (as defined in DiamondStorageLib) can pause or unpause the contract.
 * - Emits detailed events on pause, unpause, and burning actions.
 */
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
    /**
     * @notice Emitted when the contract is paused.
     * @param account The address that triggered the pause.
     */
    event Paused(address account);

    /**
     * @notice Emitted when the contract is unpaused.
     * @param account The address that triggered the unpause.
     */
    event Unpaused(address account);

    /**
     * @notice Emitted when Jiblycoin points are burned.
     * @param user The address whose tokens were burned.
     * @param amount The amount of tokens burned.
     */
    event JiblyPointsBurned(address indexed user, uint256 amount);

    // ====================================================
    // Constructor
    // ====================================================
    /**
     * @notice Initializes the burn contract.
     * @dev Sets the reentrancy status to not entered and the contract to unpaused.
     */
    constructor() {
        _status = _NOT_ENTERED;
        _paused = false;
    }

    // ====================================================
    // Modifiers
    // ====================================================
    /**
     * @notice Prevents reentrant calls to a function.
     * @dev Uses a simple status check before and after function execution.
     */
    modifier nonReentrant() {
        if (_status == _ENTERED) revert ReentrantCall();
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    /**
     * @notice Ensures that the function is executed only when the contract is not paused.
     */
    modifier whenNotPaused() {
        if (_paused) revert AlreadyPaused();
        _;
    }

    /**
     * @notice Restricts access to functions to the admin wallet.
     * @dev Checks that the caller matches the adminWallet defined in DiamondStorage.
     */
    modifier onlyAdmin() {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (msg.sender != ds.adminWallet) revert NotAuthorized();
        _;
    }

    // ====================================================
    // Public Functions
    // ====================================================
    /**
     * @notice Pauses the contract, disabling sensitive operations.
     * @dev Can only be called by the admin.
     */
    function pause() external onlyAdmin {
        if (_paused) revert AlreadyPaused();
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @notice Unpauses the contract, re-enabling operations.
     * @dev Can only be called by the admin.
     */
    function unpause() external onlyAdmin {
        if (!_paused) revert NotPaused();
        _paused = false;
        emit Unpaused(msg.sender);
    }

    /**
     * @notice Burns a specified amount of Jiblycoin points.
     * @dev Uses non-reentrancy and only executes when not paused.
     *      Reverts if the amount is zero or if the caller does not have sufficient balance.
     * @param amount The amount of tokens to burn.
     */
    function burnJiblyPoints(uint256 amount) external whenNotPaused nonReentrant {
        if (amount == 0) revert Errors.BurnZero();
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (ds.balances[msg.sender] < amount) revert Errors.InsufficientBalance();
        ds.balances[msg.sender] -= amount;
        ds.totalSupply -= amount;
        ds.totalBurned += amount;
        emit JiblyPointsBurned(msg.sender, amount);
    }
}
