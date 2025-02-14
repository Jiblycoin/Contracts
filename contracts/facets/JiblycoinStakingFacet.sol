// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinStaking } from "../staking/JiblycoinStaking.sol";
import { DiamondStorageLib } from "../libraries/DiamondStorageLib.sol";

error NotAuthorized();
error AlreadyInitialized();
error ZeroAddress();

/**
 * @title JiblycoinStakingFacet
 * @notice Facet responsible for staking functionalities within Jiblycoin.
 * @dev Extends JiblycoinStaking. Implements initialization, NFT contract address configuration,
 *      and overrides the internal NFT address retrieval function for staking exclusivity.
 *      Uses centralized storage via DiamondStorageLib and inherits non‑reentrant and pausable protections.
 */
contract JiblycoinStakingFacet is JiblycoinStaking {
    // Local storage for NFT contract address used in exclusive staking pools.
    address private nftContractAddress;

    /**
     * @notice Initializes the staking facet.
     * @dev Only callable by an account with the ADMIN_ROLE as enforced via DiamondStorageLib.
     *      Reverts if the staking pools have already been initialized.
     */
    function initStakingFacet() external {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (!hasRole(ds.ADMIN_ROLE, msg.sender)) revert NotAuthorized();
        if (ds.poolIds.length != 0) revert AlreadyInitialized();
        __jiblycoinStakingInit();
    }

    /**
     * @notice Sets the NFT contract address for verifying staking eligibility in exclusive pools.
     * @dev Only callable by an account with the UPGRADER_ROLE.
     *      Reverts if the provided address is the zero address.
     * @param _nftAddress The address of the NFT contract.
     */
    function setNFTContractAddress(address _nftAddress) external override onlyRole(UPGRADER_ROLE) {
        if (_nftAddress == address(0)) revert ZeroAddress();
        nftContractAddress = _nftAddress;
    }

    /**
     * @notice Internal function to retrieve the NFT contract address.
     * @dev Overrides the base function to return the locally stored NFT contract address.
     * @return The NFT contract address.
     */
    function _getNFTContractAddress() internal view override returns (address) {
        return nftContractAddress;
    }
}
