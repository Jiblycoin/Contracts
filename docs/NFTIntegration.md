# NFT Integration

Describes the optional JiblycoinNFT usage, including gating of pools, loyalty tiers, or special privileges.

## 1. JiblycoinNFT Contract
- **Symbol**: JBNFT
- **Minting**: Admin can call `mint(to, tokenId)`.
- **Pausing**: Not implemented yet (placeholder only).

## 2. Use Cases
- **Exclusive Staking Pools**: Some pools require `balanceOf(msg.sender) > 0` to stake.
- **Higher Loyalty Multipliers**: Owning a JBNFT could yield extra loyalty points or reduce fees.

## 3. Implementation Details
- Located in `contracts/nft/JiblycoinNFT.sol`, inherits from OpenZeppelin’s `ERC721Upgradeable`.
- Deployed once, then set in the diamond’s storage via `setNFTContractAddress(...)`.

## 4. Extending NFT Functionality
- You can add rarities, metadata expansions, or bridging features for the NFT. The contract is upgradeable, so new facets could be introduced in the future.

## 5. Minting Policies
- Initially only the `MINTER_ROLE` can mint. 
- For public minting or sales, consider adding logic for pricing, supply caps, etc.

