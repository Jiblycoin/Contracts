// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

/**
 * @title JiblycoinNFT
 * @notice ERC721 NFT contract for the Jiblycoin ecosystem.
 * @dev Implements NFT minting with role-based access control. Detailed NatSpec documentation is included for clarity.
 */
contract JiblycoinNFT is ERC721Upgradeable, AccessControlUpgradeable {
    /// @notice Role identifier for accounts allowed to mint NFTs.
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @notice Base URI for NFT metadata.
    string private _baseTokenURI;

    /**
     * @notice Emitted when an NFT is minted.
     * @param to The address receiving the NFT.
     * @param tokenId The unique token identifier for the minted NFT.
     */
    event NFTMinted(address indexed to, uint256 indexed tokenId);

    /**
     * @notice Emitted when the base URI for NFT metadata is updated.
     * @param newBaseURI The new base URI set.
     */
    event BaseURISet(string newBaseURI);

    /**
     * @notice Initializes the NFT contract.
     * @param name_ The name of the NFT collection.
     * @param symbol_ The symbol of the NFT collection.
     * @param baseURI_ The initial base URI for the metadata.
     * @param admin The address to be assigned as the admin.
     */
    function initialize(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        address admin
    ) public initializer {
        __ERC721_init(name_, symbol_);
        __AccessControl_init();
        _baseTokenURI = baseURI_;
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(MINTER_ROLE, admin);
    }

    /**
     * @notice Mints a new NFT to the specified address.
     * @dev Only accounts with the MINTER_ROLE can call this function.
     * @param to The address receiving the minted NFT.
     * @param tokenId The unique token identifier for the NFT.
     */
    function mint(address to, uint256 tokenId) external onlyRole(MINTER_ROLE) {
        _mint(to, tokenId);
        emit NFTMinted(to, tokenId);
    }

    /**
     * @notice Updates the base URI used for NFT metadata.
     * @dev Only callable by an account with the DEFAULT_ADMIN_ROLE.
     * @param baseURI_ The new base URI to be set.
     */
    function setBaseURI(string memory baseURI_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseTokenURI = baseURI_;
        emit BaseURISet(baseURI_);
    }

    /**
     * @notice Placeholder for pausing the NFT contract.
     * @dev Not implemented; calling this function will revert.
     */
    function pause() external view onlyRole(DEFAULT_ADMIN_ROLE) {
        revert("Not implemented");
    }

    /**
     * @notice Placeholder for unpausing the NFT contract.
     * @dev Not implemented; calling this function will revert.
     */
    function unpause() external view onlyRole(DEFAULT_ADMIN_ROLE) {
        revert("Not implemented");
    }

    /**
     * @notice Internal function returning the base URI for NFT metadata.
     * @return The current base URI as a string.
     */
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @notice Indicates whether the contract implements a given interface.
     * @param interfaceId The identifier of the interface.
     * @return True if the contract supports the interface, false otherwise.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
