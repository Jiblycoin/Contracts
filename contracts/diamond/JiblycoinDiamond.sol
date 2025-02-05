// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../libraries/DiamondStorageLib.sol";

contract JiblycoinDiamond {
    /**
     * @notice Constructor that sets the admin wallet and optionally initializes facets.
     * @param _admin The address of the admin.
     * @param _initCalldata The calldata for the initialization function (if any).
     */
    constructor(address _admin, bytes memory _initCalldata) {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        ds.adminWallet = _admin;
        if (_initCalldata.length > 0) {
            // slither-disable-next-line low-level-calls
            (bool success, ) = address(this).delegatecall(_initCalldata);
            require(success, "Initialization failed");
        }
    }

    // ------------------------------------------------------------------------
    // Facet Management
    // ------------------------------------------------------------------------
    struct DSFacetCut {
        address facetAddress;
        bytes4[] selectors;
    }

    /**
     * @notice Sets multiple facets by mapping function selectors to their corresponding facet addresses.
     * @param cuts An array of DSFacetCut structs.
     */
    function setFacets(DSFacetCut[] calldata cuts) external {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        require(ds.adminWallet == msg.sender, "Not authorized");
        for (uint256 i = 0; i < cuts.length; i++) {
            DSFacetCut calldata cut = cuts[i];
            for (uint256 j = 0; j < cut.selectors.length; j++) {
                ds.facets[cut.selectors[j]] = cut.facetAddress;
            }
        }
    }

    // ------------------------------------------------------------------------
    // Fallback and Receive Functions
    // ------------------------------------------------------------------------
    fallback() external payable {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        address facet = ds.facets[msg.sig];
        require(facet != address(0), "Function does not exist");
        // slither-disable-next-line no-inline-assembly
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(0, 0, size)
            switch result
            case 0 { revert(0, size) }
            default { return(0, size) }
        }
    }

    receive() external payable {}
}
