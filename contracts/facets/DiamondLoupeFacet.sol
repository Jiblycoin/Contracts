// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../libraries/DiamondStorageLib.sol";

/**
 * @title DiamondLoupeFacet
 * @notice Provides introspection functions for the diamond contract.
 * @dev This facet enables retrieval of all facets and their function selectors.
 *      It uses centralized storage from DiamondStorageLib.
 */
contract DiamondLoupeFacet {
    using DiamondStorageLib for DiamondStorageLib.DiamondStorage;

    /**
     * @notice Structure representing a facet and its function selectors.
     */
    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    /**
     * @notice Returns all facets along with their function selectors.
     * @return facets_ An array of Facet structs, each containing a facet address and its selectors.
     */
    function facets() external view returns (Facet[] memory facets_) {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        uint256 selectorsLength = ds.functionSelectors.length;
        
        // Collect unique facet addresses.
        address[] memory uniqueFacets = new address[](selectorsLength);
        uint256 uniqueCount = 0;
        for (uint256 i = 0; i < selectorsLength; i++) {
            address facetAddr = ds.facets[ds.functionSelectors[i]];
            bool exists = false;
            for (uint256 j = 0; j < uniqueCount; j++) {
                if (uniqueFacets[j] == facetAddr) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                uniqueFacets[uniqueCount] = facetAddr;
                uniqueCount++;
            }
        }
        
        // Build the facets array.
        facets_ = new Facet[](uniqueCount);
        for (uint256 i = 0; i < uniqueCount; i++) {
            address facetAddr = uniqueFacets[i];
            uint256 count = 0;
            for (uint256 j = 0; j < selectorsLength; j++) {
                if (ds.facets[ds.functionSelectors[j]] == facetAddr) {
                    count++;
                }
            }
            bytes4[] memory selectorsForFacet = new bytes4[](count);
            uint256 index = 0;
            for (uint256 j = 0; j < selectorsLength; j++) {
                if (ds.facets[ds.functionSelectors[j]] == facetAddr) {
                    selectorsForFacet[index] = ds.functionSelectors[j];
                    index++;
                }
            }
            facets_[i] = Facet({ facetAddress: facetAddr, functionSelectors: selectorsForFacet });
        }
    }

    /**
     * @notice Returns the function selectors provided by a specific facet.
     * @param facet The facet address to query.
     * @return selectors An array of function selectors associated with the facet.
     */
    function facetFunctionSelectors(address facet) external view returns (bytes4[] memory selectors) {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        uint256 selectorsLength = ds.functionSelectors.length;
        uint256 count = 0;
        for (uint256 i = 0; i < selectorsLength; i++) {
            if (ds.facets[ds.functionSelectors[i]] == facet) {
                count++;
            }
        }
        selectors = new bytes4[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < selectorsLength; i++) {
            if (ds.facets[ds.functionSelectors[i]] == facet) {
                selectors[index] = ds.functionSelectors[i];
                index++;
            }
        }
    }

    /**
     * @notice Returns all unique facet addresses deployed in the diamond.
     * @return facetAddresses_ An array of unique facet addresses.
     */
    function facetAddresses() external view returns (address[] memory facetAddresses_) {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        uint256 selectorsLength = ds.functionSelectors.length;
        address[] memory temp = new address[](selectorsLength);
        uint256 uniqueCount = 0;
        for (uint256 i = 0; i < selectorsLength; i++) {
            address facetAddr = ds.facets[ds.functionSelectors[i]];
            bool exists = false;
            for (uint256 j = 0; j < uniqueCount; j++) {
                if (temp[j] == facetAddr) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                temp[uniqueCount] = facetAddr;
                uniqueCount++;
            }
        }
        facetAddresses_ = new address[](uniqueCount);
        for (uint256 i = 0; i < uniqueCount; i++) {
            facetAddresses_[i] = temp[i];
        }
    }

    /**
     * @notice Returns the facet address associated with a given function selector.
     * @param selector The function selector to query.
     * @return The address of the facet that implements the selector.
     */
    function facetAddress(bytes4 selector) external view returns (address) {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        return ds.facets[selector];
    }
}
