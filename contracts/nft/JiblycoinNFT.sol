// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract JiblycoinNFT is ERC721Upgradeable, AccessControlUpgradeable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string private _baseTokenURI;

    event NFTMinted(address indexed to, uint256 indexed tokenId);
    event BaseURISet(string newBaseURI);

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

    function mint(address to, uint256 tokenId) external onlyRole(MINTER_ROLE) {
        _mint(to, tokenId);
        emit NFTMinted(to, tokenId);
    }

    function setBaseURI(string memory baseURI_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseTokenURI = baseURI_;
        emit BaseURISet(baseURI_);
    }

    function pause() external view onlyRole(DEFAULT_ADMIN_ROLE) {
        revert("Not implemented");
    }

    function unpause() external view onlyRole(DEFAULT_ADMIN_ROLE) {
        revert("Not implemented");
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    uint256[50] private __gap;
}
