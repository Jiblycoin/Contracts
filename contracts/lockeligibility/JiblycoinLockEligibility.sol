// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinCore } from "../core/JiblycoinCore.sol";
import { JiblycoinStructs as JStructs } from "../structs/JiblycoinStructs.sol";

abstract contract JiblycoinLockEligibility is JiblycoinCore {
    error LockZero();
    error DurationZeroLI();
    error InsuffBalLI();
    error ZeroAddressLI();

    uint256 public redistributionPool;
    mapping(address => uint256) public lockedTokens;
    mapping(address => uint256) public lockExpiry;
    mapping(address => JStructs.VestingParameters) public teamVesting;

    event TokensLocked(address indexed user, uint256 amount, uint256 unlockTime);
    event TokensUnlocked(address indexed user, uint256 amount);
    event RedistributionPoolAdjusted(uint256 newAmount);
    event TeamVestingInitialized(address indexed beneficiary, uint256 amount, uint64 vestingDuration, uint64 cliffDuration);

    function __JiblycoinLockEligibility_init(uint256 _redistributionPool) internal onlyInitializing {
        redistributionPool = _redistributionPool;
    }

    function lockTokens(uint256 amount, uint256 duration) external whenNotPaused nonReentrant {
        if (amount == 0) revert LockZero();
        if (duration == 0) revert DurationZeroLI();
        if (balanceOf(msg.sender) < amount) revert InsuffBalLI();
        lockedTokens[msg.sender] += amount;
        lockExpiry[msg.sender] = block.timestamp + duration;
        _transfer(msg.sender, address(this), amount);
        emit TokensLocked(msg.sender, amount, lockExpiry[msg.sender]);
    }

    function lockTokensFor(address user, uint256 amount, uint256 duration) public onlyRole(ADMIN_ROLE) whenNotPaused nonReentrant {
        if (amount == 0) revert LockZero();
        if (user == address(0)) revert ZeroAddressLI();
        if (balanceOf(msg.sender) < amount) revert InsuffBalLI();
        lockedTokens[user] += amount;
        lockExpiry[user] = block.timestamp + duration;
        _transfer(msg.sender, address(this), amount);
        emit TokensLocked(user, amount, lockExpiry[user]);
    }

    function unlockTokens() external whenNotPaused nonReentrant {
        if (block.timestamp < lockExpiry[msg.sender]) revert DurationZeroLI();
        uint256 amount = lockedTokens[msg.sender];
        if (amount == 0) revert LockZero();
        lockedTokens[msg.sender] = 0;
        lockExpiry[msg.sender] = 0;
        _transfer(address(this), msg.sender, amount);
        emit TokensUnlocked(msg.sender, amount);
    }

    function adjustRedistributionPool(uint256 newAmount) external onlyRole(ADMIN_ROLE) {
        redistributionPool = newAmount;
        emit RedistributionPoolAdjusted(newAmount);
    }

    function initializeTeamVesting(
        address beneficiary,
        uint256 amount,
        uint64 vestingDuration,
        uint64 cliffDuration
    ) external onlyRole(ADMIN_ROLE) {
        if (beneficiary == address(0)) revert ZeroAddressLI();
        if (amount == 0) revert LockZero();
        if (vestingDuration == 0) revert DurationZeroLI();
        if (balanceOf(address(this)) < amount) revert InsuffBalLI();
        teamVesting[beneficiary] = JStructs.VestingParameters({
            totalVestedAmount: amount,
            vestingStartTimestamp: uint64(block.timestamp),
            vestingDuration: vestingDuration,
            cliffDuration: cliffDuration
        });
        _transfer(address(this), beneficiary, amount);
        emit TeamVestingInitialized(beneficiary, amount, vestingDuration, cliffDuration);
    }
    
    uint256[50] private __gap;
}
