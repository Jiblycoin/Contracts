// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { DiamondStorageLib } from "../libraries/DiamondStorageLib.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol"; // Import the Address library

// Custom errors can be defined in your Errors.sol file;
// For this example, we'll assume they are defined as follows:
error InitializationFailed();
error FunctionDoesNotExist();
error NotAuthorized();

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
            // Use OpenZeppelin's functionDelegateCall instead of a low-level delegatecall.
            // This avoids low-level calls and performs error checking internally.
            // If the call fails, the helper will revert.
            Address.functionDelegateCall(address(this), _initCalldata);
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
        if (msg.sender != ds.adminWallet) revert NotAuthorized();
        for (uint256 i = 0; i < cuts.length; i++) {
            DSFacetCut calldata cut = cuts[i];
            for (uint256 j = 0; j < cut.selectors.length; j++) {
                ds.facets[cut.selectors[j]] = cut.facetAddress;
                // Optionally, you could check if the selector already exists in ds.functionSelectors
                // and add it if not present.
            }
        }
    }

    // ------------------------------------------------------------------------
    // Fallback and Receive Functions
    // ------------------------------------------------------------------------
    /**
     * @notice Fallback function that delegates calls to the appropriate facet.
     * @dev Uses OpenZeppelin's Address.functionDelegateCall for delegation.
     *      Inline assembly is used only to return the result.
     */
    fallback() external payable {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        address facet = ds.facets[msg.sig];
        if (facet == address(0)) revert FunctionDoesNotExist();
        bytes memory result = Address.functionDelegateCall(facet, msg.data);
        // solhint-disable-next-line no-inline-assembly
        assembly {
            return(add(result, 32), mload(result))
        }
    }

    /**
     * @notice Receive function to accept plain Ether transfers.
     */
    receive() external payable {}
}
