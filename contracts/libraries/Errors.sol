// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title Errors
 * @notice Defines custom errors used throughout the Jiblycoin ecosystem.
 * @dev Using custom errors instead of revert strings provides gas savings during failed executions.
 */
library Errors {
    /// @notice Thrown when an attempt is made to burn zero tokens.
    error BurnZero();

    /// @notice Thrown when an operation is attempted with an insufficient token balance.
    error InsufficientBalance();

    /// @notice Thrown as an alternative insufficient balance error.
    error InsuffBal();

    /// @notice Thrown when an action is attempted that has already been claimed.
    error AlreadyClaimed();

    /// @notice Thrown when an operation exceeds the allowed rate limit.
    error RateLimitExceeded();

    /// @notice Thrown when a function call is attempted while the circuit breaker is active.
    error CircuitActive();

    /// @notice Thrown when a zero address is provided where a non‑zero address is expected.
    error ZeroAddress();

    /// @notice Thrown when an oracle required for an operation is not set.
    error OracleNotSet();

    /// @notice Thrown when a transaction amount exceeds the maximum allowed size.
    error TxExceedsMax();

    /// @notice Thrown when a wallet balance would exceed the maximum allowed limit.
    error WalletExceedsMax();

    /// @notice Thrown when a proposal is created without a description.
    error NoDescription();

    /// @notice Thrown when a proposal is created without a category.
    error NoCategory();

    /// @notice Thrown when a provided execution time is zero.
    error ExecTimeZero();

    /// @notice Thrown when a reward or points cap is exceeded.
    error PointsCapExceeded();

    /// @notice Thrown when an operation is attempted with a blacklisted address.
    error Blacklisted();

    // Additional errors for staking:
    error PoolDoesNotExist();
    error CannotStakeZero();
    error MustHoldNFT();
    error InsufficientStakedBalance();
}
