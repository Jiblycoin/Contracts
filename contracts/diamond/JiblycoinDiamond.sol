// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../libraries/DiamondStorageLib.sol";

/**
 * @title JiblycoinDiamond
 * @notice Acts as the central proxy for the Jiblycoin system, delegating calls to registered facets.
 * @dev Implements the diamond storage pattern via DiamondStorageLib. Only the admin can update facets.
 *      All calls that do not match any function in this contract are delegated to the corresponding facet.
 */
contract JiblycoinDiamond {
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    /**
     * @notice Sets the admin wallet and optionally initializes facets.
     * @param _admin The address to be set as the admin.
     * @param _initCalldata Optional calldata for initializing facets; if provided, it is delegatecalled.
     */
    constructor(address _admin, bytes memory _initCalldata) {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        ds.adminWallet = _admin;
        if (_initCalldata.length > 0) {
            // Delegatecall to the provided initialization function.
            (bool success, ) = address(this).delegatecall(_initCalldata);
            require(success, "Initialization failed");
        }
    }

    // ------------------------------------------------------------------------
    // Facet Management
    // ------------------------------------------------------------------------
    /**
     * @notice Structure representing a facet cut used to update facet mappings.
     * @param facetAddress The address of the facet.
     * @param selectors An array of function selectors associated with the facet.
     */
    struct DSFacetCut {
        address facetAddress;
        bytes4[] selectors;
    }

    /**
     * @notice Updates multiple facets by mapping their function selectors to corresponding facet addresses.
     * @dev Only callable by the admin. This function updates the centralized mapping used for delegatecalls.
     * @param cuts An array of DSFacetCut structs specifying facet addresses and their selectors.
     */
    function setFacets(DSFacetCut[] calldata cuts) external {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        require(ds.adminWallet == msg.sender, "Not authorized");
        for (uint256 i = 0; i < cuts.length; i++) {
            DSFacetCut calldata cut = cuts[i];
            for (uint256 j = 0; j < cut.selectors.length; j++) {
                ds.facets[cut.selectors[j]] = cut.facetAddress;
                // Optionally, add the selector to the functionSelectors array if not already present.
            }
        }
    }

    // ------------------------------------------------------------------------
    // Fallback and Receive Functions
    // ------------------------------------------------------------------------
    /**
     * @notice Fallback function that delegates calls to the appropriate facet.
     * @dev Uses inline assembly for efficiency. The function selector (msg.sig) is used to determine the facet.
     */
    fallback() external payable {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        address facet = ds.facets[msg.sig];
        require(facet != address(0), "Function does not exist");
        assembly {
            // Copy msg.data.
            calldatacopy(0, 0, calldatasize())
            // Delegatecall to the facet.
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // Retrieve returned data size.
            let size := returndatasize()
            // Copy returned data.
            returndatacopy(0, 0, size)
            // Revert on error, return on success.
            switch result
            case 0 { revert(0, size) }
            default { return(0, size) }
        }
    }

    /**
     * @notice Receive function to accept plain Ether transfers.
     */
    receive() external payable {}
}
