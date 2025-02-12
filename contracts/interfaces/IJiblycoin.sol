// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../structs/JiblycoinStructs.sol";

/**
 * @title IJiblycoin
 * @notice Interface for the Jiblycoin core contract.
 * @dev Exposes functions for querying fee parameters and other essential state variables.
 */
interface IJiblycoin {
    /**
     * @notice Retrieves the current fee parameters.
     * @return feeParams The fee parameters as defined in JiblycoinStructs.FeeParameters.
     */
    function getFeeParameters() external view returns (JiblycoinStructs.FeeParameters memory feeParams);
}
