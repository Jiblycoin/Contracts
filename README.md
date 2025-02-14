# Jiblycoin

An upgradeable, diamond-pattern ERC20 token on Binance Smart Chain (BSC) with staking, governance, bridging, burn mechanics, loyalty rewards, and optional NFT gating.

## Key Features
- **Diamond Architecture**: Modular and upgradeable facets
- **Staking**: Stake tokens in multiple pools
- **Governance**: On-chain proposals, voting, and execution
- **Loyalty Rewards**: Referral system, holding bonuses, monthly burn/buyback
- **Bridging**: Cross-chain bridging via Allbridge
- **NFT Integration**: Optional NFT-based exclusivity for certain features
- **Upgradeable**: Timelocked upgrades with admin roles

## Repository Structure
- `contracts/` – Main Solidity source (facets, libraries, diamond core)
- `scripts/` – Deployment and management scripts
- `tests/` – Automated tests using Hardhat/Chai
- `docs/` – Detailed documentation

## Getting Started
1. **Install Dependencies**: `npm install` or `yarn install`
2. **Compile**: `npx hardhat compile`
3. **Test**: `npx hardhat test`
4. **Deploy**: `npx hardhat run scripts/deploy.js --network bscTestnet`
   - Ensure you have a `.env` with your PRIVATE_KEY and RPC URLs

## Documentation
- [SmartContractArchitecture.md](./docs/SmartContractArchitecture.md)  
- [TokenomicsOverview.md](./docs/TokenomicsOverview.md)  
- [GovernanceMechanism.md](./docs/GovernanceMechanism.md)  
- [StakingGuide.md](./docs/StakingGuide.md)  
- [NFTIntegration.md](./docs/NFTIntegration.md)  
- [UpgradeGuide.md](./docs/UpgradeGuide.md)  
- [CrossChainBridge.md](./docs/CrossChainBridge.md)  
- [Audit-Solhint.md](./Audits/Audit-Solhint.md)

## Security
- Built-in pausable & circuit breaker logic
- Reentrancy guards
- Admin role-based access
- **Audit recommended** before mainnet launch

## License
[MIT](./LICENSE)

