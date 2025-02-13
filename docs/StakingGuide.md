# Staking Guide

This guide covers how to stake JIBLY tokens, claim rewards, and manage your staking positions within the Jiblycoin ecosystem.

## 1. Staking Pools
- **Multiple Pools**: There are different pools with distinct reward rates and eligibility criteria.
  - **Standard Pools**: Open to all token holders.
  - **Exclusive Pools**: May require ownership of a JiblycoinNFT to participate.

## 2. How to Stake Tokens
1. **Connect Your Wallet**: Use a supported wallet (e.g., MetaMask) on the Binance Smart Chain.
2. **Approval (if required)**: Allow the staking facet to spend your tokens.
3. **Stake**: Call the function `stake(poolId, amount)`.
   - In exclusive pools, the contract checks:
     ```solidity
     if (nftContract.balanceOf(msg.sender) == 0) revert MustHoldNFT();
     ```
4. **Reward Accumulation**: Rewards are computed based on:
   - The pool’s `baseRewardRate`
   - Adjustments from the `marketConditionFactor` (updated via the Oracle)
   - Elapsed time since your last claim or stake

## 3. Claiming Rewards
- Call `claimRewards(poolId)` to transfer your accrued rewards.
- Reward calculations update based on the last reward timestamp and the user’s staked amount.

## 4. Unstaking Tokens
- To withdraw, call `unstake(poolId, amount)`.
- Note any restrictions or cooldowns that may apply depending on the pool’s configuration.

## 5. Monitoring Your Stake
- **Staked Amounts**: Stored in `stakedAmounts[poolId][user]`.
- **Accrued Rewards**: Tracked in `rewardDebt[poolId][user]`.

## 6. Common Errors
- **PoolDoesNotExist**: The pool ID specified is invalid.
- **CannotStakeZero**: You must stake a non-zero token amount.
- **MustHoldNFT**: Exclusive pools require that you own a JiblycoinNFT.
- **InsufficientStakedBalance**: You are attempting to unstake more than your staked balance.
