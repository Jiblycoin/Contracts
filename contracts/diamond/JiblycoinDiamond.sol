// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Import DiamondStorageLib with a namespace alias to avoid naming conflicts.
import { DiamondStorageLib as DS } from "../libraries/DiamondStorageLib.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";

// Custom errors
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
        DS.DiamondStorage storage ds = DS.diamondStorage();
        ds.adminWallet = _admin;
        if (_initCalldata.length > 0) {
            // Use OpenZeppelin's functionDelegateCall for safe delegatecall.
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
        DS.DiamondStorage storage ds = DS.diamondStorage();
        if (msg.sender != ds.adminWallet) revert NotAuthorized();
        for (uint256 i = 0; i < cuts.length; i++) {
            DSFacetCut calldata cut = cuts[i];
            for (uint256 j = 0; j < cut.selectors.length; j++) {
                ds.facets[cut.selectors[j]] = cut.facetAddress;
                // Optionally: add the selector to ds.functionSelectors if not already present.
            }
        }
    }

    // ------------------------------------------------------------------------
    // Fallback and Receive Functions
    // ------------------------------------------------------------------------
    /**
     * @notice Fallback function that delegates calls to the appropriate facet.
     */
    fallback() external payable {
        _fallback();
    }

    /**
     * @dev Internal function to perform the delegatecall and return the result.
     */
    function _fallback() private {
        DS.DiamondStorage storage ds = DS.diamondStorage();
        address facet = ds.facets[msg.sig];
        if (facet == address(0)) revert FunctionDoesNotExist();
        // Perform the delegatecall using Address.functionDelegateCall.
        bytes memory result = Address.functionDelegateCall(facet, msg.data);
        // Inline assembly is necessary here per the diamond standard.
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