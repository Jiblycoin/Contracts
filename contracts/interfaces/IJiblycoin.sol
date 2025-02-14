// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Use a named import with an alias for the structs
import { JiblycoinStructs as JStructs } from "../structs/JiblycoinStructs.sol";

/**
 * @title IJiblycoin
 * @notice Interface for the Jiblycoin core contract.
 * @dev Exposes functions for querying fee parameters and other essential state variables.
 */
interface IJiblycoin {
    /**
     * @notice Retrieves the current fee parameters.
     * @return feeParams The fee parameters as defined in JStructs.FeeParameters.
     */
    function getFeeParameters() external view returns (JStructs.FeeParameters memory feeParams);
}
