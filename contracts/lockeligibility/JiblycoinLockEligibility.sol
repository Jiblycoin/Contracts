// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinCore } from "../core/JiblycoinCore.sol";
import { JiblycoinStructs } from "../structs/JiblycoinStructs.sol";
import { Errors } from "../libraries/Errors.sol";

/**
 * @title JiblycoinLockEligibility
 * @notice Provides functionalities for locking tokens to gain eligibility for additional rewards.
 * @dev Extends JiblycoinCore to incorporate token locking mechanisms. This contract manages locked tokens,
 *      lock expiry, and team vesting parameters.
 *      It uses custom errors from Errors.sol to optimize gas consumption.
 */
abstract contract JiblycoinLockEligibility is JiblycoinCore {
    // ====================================================
    // State Variables
    // ====================================================
    /// @notice Redistribution pool allocated for locked tokens.
    uint256 public redistributionPool;
    /// @notice Mapping of locked token amounts per address.
    mapping(address => uint256) public lockedTokens;
    /// @notice Mapping of lock expiry timestamps per address.
    mapping(address => uint256) public lockExpiry;
    /// @notice Mapping of team vesting parameters for addresses.
    mapping(address => JiblycoinStructs.VestingParameters) public teamVesting;

    // ====================================================
    // Events
    // ====================================================
    /**
     * @notice Emitted when tokens are locked.
     * @param user The address locking tokens.
     * @param amount The amount of tokens locked.
     * @param unlockTime The timestamp when tokens become unlockable.
     */
    event TokensLocked(address indexed user, uint256 amount, uint256 unlockTime);

    /**
     * @notice Emitted when tokens are unlocked.
     * @param user The address unlocking tokens.
     * @param amount The amount of tokens unlocked.
     */
    event TokensUnlocked(address indexed user, uint256 amount);

    /**
     * @notice Emitted when the redistribution pool is adjusted.
     * @param newAmount The new value of the redistribution pool.
     */
    event RedistributionPoolAdjusted(uint256 newAmount);

    /**
     * @notice Emitted when team vesting is initialized.
     * @param beneficiary The address receiving vested tokens.
     * @param amount The total amount vested.
     * @param vestingDuration The duration of the vesting period in seconds.
     * @param cliffDuration The duration of the cliff period in seconds.
     */
    event TeamVestingInitialized(address indexed beneficiary, uint256 amount, uint64 vestingDuration, uint64 cliffDuration);

    // ====================================================
    // Initializer Function
    // ====================================================
    /**
     * @notice Initializes the lock eligibility module.
     * @dev Sets the initial redistribution pool for locked tokens.
     * @param _redistributionPool The initial amount allocated to the redistribution pool.
     */
    function initializeLockEligibilityModule(uint256 _redistributionPool) internal onlyInitializing {
        redistributionPool = _redistributionPool;
    }

    // ====================================================
    // Locking Functions
    // ====================================================
    /**
     * @notice Locks a specified amount of tokens for a given duration.
     * @dev Reverts with Errors.BurnZero if the amount is zero,
     *      Errors.ExecTimeZero if the duration is zero,
     *      or Errors.InsufficientBalance if the caller's balance is insufficient.
     *      Transfers tokens from the caller to the contract.
     * @param amount The amount of tokens to lock.
     * @param duration The duration (in seconds) to lock the tokens.
     */
    function lockTokens(uint256 amount, uint256 duration)
        external
        whenNotPaused
        nonReentrant
    {
        if (amount == 0) revert Errors.BurnZero(); // Using BurnZero as a proxy for "LockZero"
        if (duration == 0) revert Errors.ExecTimeZero(); // Proxy error for zero duration
        if (balanceOf(msg.sender) < amount) revert Errors.InsufficientBalance();
        lockedTokens[msg.sender] += amount;
        lockExpiry[msg.sender] = block.timestamp + duration;
        _transfer(msg.sender, address(this), amount);
        emit TokensLocked(msg.sender, amount, lockExpiry[msg.sender]);
    }

    /**
     * @notice Locks tokens on behalf of another user.
     * @dev Reverts with Errors.BurnZero if the amount is zero,
     *      Errors.ZeroAddress if the target user is the zero address,
     *      or Errors.InsufficientBalance if the caller's balance is insufficient.
     * @param user The address for which tokens will be locked.
     * @param amount The amount of tokens to lock.
     * @param duration The duration (in seconds) for which tokens will be locked.
     */
    function lockTokensFor(
        address user,
        uint256 amount,
        uint256 duration
    ) public onlyRole(ADMIN_ROLE) whenNotPaused nonReentrant {
        if (amount == 0) revert Errors.BurnZero();
        if (user == address(0)) revert Errors.ZeroAddress();
        if (balanceOf(msg.sender) < amount) revert Errors.InsufficientBalance();
        lockedTokens[user] += amount;
        lockExpiry[user] = block.timestamp + duration;
        _transfer(msg.sender, address(this), amount);
        emit TokensLocked(user, amount, lockExpiry[user]);
    }

    /**
     * @notice Unlocks tokens if the lock duration has expired.
     * @dev Reverts if the current time is before the lock expiry or if no tokens are locked.
     */
    function unlockTokens() external whenNotPaused nonReentrant {
        if (block.timestamp < lockExpiry[msg.sender]) revert Errors.ExecTimeZero(); // Early unlock attempt
        uint256 amount = lockedTokens[msg.sender];
        if (amount == 0) revert Errors.BurnZero(); // No locked tokens
        lockedTokens[msg.sender] = 0;
        lockExpiry[msg.sender] = 0;
        _transfer(address(this), msg.sender, amount);
        emit TokensUnlocked(msg.sender, amount);
    }

    // ====================================================
    // Administrative Functions
    // ====================================================
    /**
     * @notice Adjusts the redistribution pool.
     * @dev Only callable by an account with the ADMIN_ROLE.
     * @param newAmount The new redistribution pool amount.
     */
    function adjustRedistributionPool(uint256 newAmount)
        external
        onlyRole(ADMIN_ROLE)
    {
        redistributionPool = newAmount;
        emit RedistributionPoolAdjusted(newAmount);
    }

    /**
     * @notice Initializes team vesting parameters.
     * @dev Reverts with Errors.ZeroAddress if the beneficiary is the zero address,
     *      Errors.BurnZero if the amount is zero,
     *      Errors.ExecTimeZero if the vesting duration is zero,
     *      or Errors.InsufficientBalance if the contract does not have enough tokens.
     *      Transfers the vested tokens to the beneficiary.
     * @param beneficiary The address receiving the vested tokens.
     * @param amount The total amount to vest.
     * @param vestingDuration The vesting period in seconds.
     * @param cliffDuration The cliff period in seconds.
     */
    function initializeTeamVesting(
        address beneficiary,
        uint256 amount,
        uint64 vestingDuration,
        uint64 cliffDuration
    ) external onlyRole(ADMIN_ROLE) {
        if (beneficiary == address(0)) revert Errors.ZeroAddress();
        if (amount == 0) revert Errors.BurnZero();
        if (vestingDuration == 0) revert Errors.ExecTimeZero();
        if (balanceOf(address(this)) < amount) revert Errors.InsufficientBalance();
        teamVesting[beneficiary] = JiblycoinStructs.VestingParameters({
            totalVestedAmount: amount,
            vestingStartTimestamp: uint64(block.timestamp),
            vestingDuration: vestingDuration,
            cliffDuration: cliffDuration
        });
        _transfer(address(this), beneficiary, amount);
        emit TeamVestingInitialized(beneficiary, amount, vestingDuration, cliffDuration);
    }
}
