# Staking Guide

This guide explains how to stake JIBLY tokens and claim rewards.

## 1. Staking Pools
- **Multiple Pools**: Each pool has different reward rates and possibly different requirements.
  - e.g. Standard Pool, Exclusive Pool (NFT required), etc.

## 2. Stake Tokens
1. **Connect Wallet**: e.g. MetaMask on BSC.
2. **Approve**: Approve the staking facet to spend your tokens (if required).
3. **Stake**: Call `stake(poolId, amount)`. 
   - If “exclusive,” must hold a JiblyNFT: 
     ```solidity
     if (nftContract.balanceOf(msg.sender) == 0) revert MustHoldNFT();
     ```

## 3. Claim Rewards
- Rewards accrue over time. 
- Call `claimRewards(poolId)` to transfer accrued rewards to your wallet. 
- Reward calculations consider:
  - `baseRewardRate` for the pool
  - `marketConditionFactor` from the oracle
  - Time elapsed since last claim

## 4. Unstake
- Call `unstake(poolId, amount)`. 
- Subject to any early withdrawal fees or time locks (if configured).

## 5. Tracking & UI
- You can see staked amounts in the `stakedAmounts[poolId][user]`.
- Reward details in `rewardDebt[poolId][user]`.

## 6. Common Errors
- **PoolDoesNotExist**: Invalid poolId.
- **CannotStakeZero**: Attempted to stake 0 tokens.
- **MustHoldNFT**: If it’s an exclusive pool but user has no JiblyNFT.

