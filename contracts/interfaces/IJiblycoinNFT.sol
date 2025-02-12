// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title IJiblycoinNFT
 * @notice Interface for the Jiblycoin NFT contract.
 * @dev Exposes functions for minting NFTs, querying NFT balances, and controlling the base URI.
 */
interface IJiblycoinNFT {
    /**
     * @notice Mints an NFT with the given token ID to the specified address.
     * @param to The address that will receive the minted NFT.
     * @param tokenId The unique identifier for the NFT.
     */
    function mint(address to, uint256 tokenId) external;

    /**
     * @notice Returns the number of NFTs owned by the given address.
     * @param owner The address to query.
     * @return The number of NFTs owned.
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @notice Sets the base URI for all NFT metadata.
     * @param baseURI_ The new base URI to set.
     */
    function setBaseURI(string memory baseURI_) external;

    /**
     * @notice Pauses the NFT contract, disabling minting and transfers.
     */
    function pause() external;

    /**
     * @notice Unpauses the NFT contract, enabling operations.
     */
    function unpause() external;
}
