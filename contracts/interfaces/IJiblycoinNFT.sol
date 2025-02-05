// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IJiblycoinNFT {
    function mint(address to, uint256 tokenId) external;
    function balanceOf(address owner) external view returns (uint256);
    function setBaseURI(string memory baseURI_) external;
    function pause() external;
    function unpause() external;
}
