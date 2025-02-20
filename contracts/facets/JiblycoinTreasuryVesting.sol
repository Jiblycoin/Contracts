// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { JiblycoinCore } from "../core/JiblycoinCore.sol";

// -----------------
// Custom Errors
// -----------------
error InvalidTokenAddress();
error NoTokensAvailableForClaim();
error InvalidVestingSchedule();
error InsufficientContractBalance();
error TransferFailed();

/**
 * @title JiblycoinTreasuryVesting
 * @notice This contract holds a portion of treasury tokens and releases them gradually according to a vesting schedule.
 * @dev Tokens are locked until the cliff period ends, after which they vest linearly until the end of the vesting period.
 */
contract JiblycoinTreasuryVesting is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    /// @notice Total number of tokens locked for the treasury.
    uint256 public totalLocked;
    /// @notice Total tokens that have been claimed so far.
    uint256 public claimed;
    /// @notice The timestamp when vesting starts.
    uint256 public vestingStart;
    /// @notice The cliff period (in seconds) before any tokens vest.
    uint256 public cliffDuration;
    /// @notice Total vesting duration (in seconds).
    uint256 public vestingDuration;
    /// @notice Reference to the JiblycoinCore token contract.
    JiblycoinCore public token;

    /// @notice Emitted when vested tokens are claimed.
    event TokensClaimed(uint256 amountClaimed, uint256 totalClaimed);
    /// @notice Emitted when the vesting schedule is initialized.
    event VestingInitialized(uint256 totalLocked, uint256 vestingStart, uint256 cliffDuration, uint256 vestingDuration);

    /**
     * @notice Initializes the Treasury Vesting contract.
     * @param _token The address of the JiblycoinCore token contract.
     * @param _totalLocked The total number of tokens to lock for treasury purposes.
     * @param _vestingStart The timestamp when vesting begins (typically at launch).
     * @param _cliffDuration The duration (in seconds) of the cliff period.
     * @param _vestingDuration The total vesting duration (in seconds).
     */
    function initialize(
        address _token,
        uint256 _totalLocked,
        uint256 _vestingStart,
        uint256 _cliffDuration,
        uint256 _vestingDuration
    ) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();

        if (_token == address(0)) revert InvalidTokenAddress();
        if (_vestingDuration < _cliffDuration) revert InvalidVestingSchedule();

        token = JiblycoinCore(_token);
        totalLocked = _totalLocked;
        vestingStart = _vestingStart;
        cliffDuration = _cliffDuration;
        vestingDuration = _vestingDuration;

        emit VestingInitialized(_totalLocked, _vestingStart, _cliffDuration, _vestingDuration);
    }

    /**
     * @notice Returns the amount of tokens that have vested so far.
     */
    function vestedAmount() public view returns (uint256) {
        if (block.timestamp < vestingStart + cliffDuration) {
            return 0;
        } else if (block.timestamp >= vestingStart + vestingDuration) {
            return totalLocked;
        } else {
            uint256 timeElapsed = block.timestamp - vestingStart;
            return (totalLocked * timeElapsed) / vestingDuration;
        }
    }

    /**
     * @notice Allows the owner (treasury) to claim vested tokens.
     * @dev The claimable amount is the difference between the vested amount and what’s already been claimed.
     *      Also checks that the contract holds sufficient tokens and that the token transfer is successful.
     */
    function claimTokens() external nonReentrant onlyOwner {
        uint256 vested = vestedAmount();
        uint256 claimable = vested - claimed;
        if (claimable == 0) revert NoTokensAvailableForClaim();

        // Ensure the vesting contract holds enough tokens.
        uint256 contractBalance = token.balanceOf(address(this));
        if (contractBalance < claimable) revert InsufficientContractBalance();

        claimed += claimable;
        // Transfer the claimable tokens from this contract to the treasury (owner).
        bool success = token.transfer(owner(), claimable);
        if (!success) revert TransferFailed();

        emit TokensClaimed(claimable, claimed);
    }
}
