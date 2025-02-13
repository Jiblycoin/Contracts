# NFT Integration

This document explains how the JiblycoinNFT contract is integrated into the ecosystem to provide exclusive features and enhanced user incentives.

## 1. JiblycoinNFT Contract
- **Token Symbol**: JBNFT
- **Minting**:
  - Admins with the `MINTER_ROLE` can mint NFTs by calling `mint(to, tokenId)`.
- **Upgradeable**:
  - Built on OpenZeppelin’s ERC721Upgradeable, the contract is upgradeable.
- **Pausing**:
  - Pause functions are currently placeholders; future work may add full pause/unpause capabilities.

## 2. Use Cases
- **Exclusive Staking Pools**:
  - Certain staking pools require that users hold at least one JBNFT (verified via `balanceOf(msg.sender)`).
- **Enhanced Loyalty Rewards**:
  - Ownership of JBNFTs may provide additional loyalty multipliers or reduce transaction fees.
- **Future Extensions**:
  - Potential for rarities, expanded metadata, or integration with bridging mechanisms.

## 3. Integration Details
- **Deployment**: The NFT contract is deployed separately from the diamond.
- **Configuration**: Its address is stored in diamond storage via `setNFTContractAddress(...)` and is referenced by facets (e.g., Staking Facet) to enforce NFT-based eligibility.
- **Security**: Only authorized roles can mint or modify NFT settings.
