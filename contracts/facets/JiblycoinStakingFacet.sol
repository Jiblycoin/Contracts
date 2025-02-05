// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../staking/JiblycoinStaking.sol";
import "../libraries/DiamondStorageLib.sol";
import "../interfaces/IJiblycoinNFT.sol";

contract JiblycoinStakingFacet is JiblycoinStaking {
    address private nftContractAddress;

    /**
     * @notice Initializes the staking facet.
     */
    function initStakingFacet() external {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        require(hasRole(ds.ADMIN_ROLE, msg.sender), "Not authorized");
        require(ds.poolIds.length == 0, "Already initialized");
        __JiblycoinStaking_init();
    }

    /**
     * @notice Sets the NFT contract address to be used in staking checks.
     */
    function setNFTContractAddress(address _nftAddress) external override onlyRole(UPGRADER_ROLE) {
        require(_nftAddress != address(0), "Zero address");
        nftContractAddress = _nftAddress;
    }

    /**
     * @notice Overrides the internal function to return the NFT contract address.
     * @return The NFT contract address.
     */
    function _getNFTContractAddress() internal view override returns (address) {
        return nftContractAddress;
    }
}
