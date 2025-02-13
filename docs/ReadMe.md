# Jiblycoin

An upgradeable, diamond-pattern ERC20 token on Binance Smart Chain (BSC) featuring staking, governance, bridging, burn mechanics, loyalty rewards, and optional NFT gating.

## Key Features
- **Diamond Architecture**: Modular and upgradeable facets for flexibility and ease of maintenance.
- **Staking**: Stake tokens in multiple pools to earn rewards, with support for both standard and NFT-gated pools.
- **Governance**: On-chain proposals, voting, delegation, and execution for decentralized decision making.
- **Loyalty Rewards**: Referral system and holding bonuses, including monthly burn/buyback triggers.
- **Bridging**: Cross-chain token transfers via Allbridge for broader liquidity.
- **NFT Integration**: Optional NFT-based exclusivity that can enhance loyalty rewards or access exclusive staking pools.
- **Chainlink VRF Integration**: Secure randomness is available for random reward distributions and other use cases.
- **Upgradable System**: Timelocked upgrades using UUPS pattern with strict role-based access.

## Repository Structure
- **contracts/** – Main Solidity source code including facets, libraries, and the diamond core.
- **scripts/** – Deployment and management scripts.
- **tests/** – Automated tests using Hardhat/Chai.
- **docs/** – Detailed documentation including architecture, tokenomics, governance, staking, NFT integration, upgrade guides, and cross-chain bridging.

## Getting Started

1. **Install Dependencies**  
   Use npm or yarn to install project dependencies:  
   ```bash
   npm install
   # or
   yarn install
