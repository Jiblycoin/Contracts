// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library Errors {
    error BurnZero();
    error InsufficientBalance();
    error InsuffBal();
    error AlreadyClaimed();
    error RateLimitExceeded();
    error CircuitActive();
    error ZeroAddress();
    error OracleNotSet();
    error TxExceedsMax();
    error WalletExceedsMax();
    error NoDescription();
    error NoCategory();
    error ExecTimeZero();
    error PointsCapExceeded();
    error Blacklisted();
}
