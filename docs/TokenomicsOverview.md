# Tokenomics Overview

This document breaks down Jiblycoin’s supply, allocation, fees, and deflationary mechanisms.

## 1. Initial Supply
- **Total Supply**: 10,000,000 JIBLY
- **Wallet Allocations**:
  - Admin Wallet: 5%
  - Main Wallet: 55%
  - Development: 15%
  - Rewards/Airdrops: 10%
  - Collaboration/Marketing: 5%
  - Burn Address: 5%
  - Buyback Wallet: 5%

## 2. Fee Structure
1. **Base Fee**: 1% (adjustable by `marketConditionFactor`)
2. **Redistribution Fee**: 2%
3. **Burn Fee**: 1%
4. **Buyback Fee**: 1%
5. **JiblyHood Fee**: 0.5%

These fees are summed up on transfers and distributed to respective wallets/pools.  
> **Dynamic Factor**: Our Oracle can adjust `marketConditionFactor` to scale the base fee up/down under certain conditions.

## 3. Deflationary Mechanisms
- **Burn**: A portion of every transaction is sent to the burn address (`0x000...dEaD`).
- **Manual Burn**: Admin can trigger monthly burns/buybacks if certain thresholds are met.
- **Staking**: Rewards are minted from an existing pool, not newly minted supply, so no net inflation.

## 4. Loyalty & Referral
- Additional tokens allocated for loyalty bonuses and referral incentives.
- Potential “Loyalty Tiers” based on holding duration and NFT ownership.

## 5. Long-Term Goals
- Gradually reduce circulating supply via monthly burns
- Encourage holding/staking to reduce sell pressure
- Support cross-chain bridging for broader liquidity

