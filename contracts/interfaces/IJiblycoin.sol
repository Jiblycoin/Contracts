// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../structs/JiblycoinStructs.sol";

/**
 * @title IJiblycoin
 * @dev Interface for the Jiblycoin contract.
 */
interface IJiblycoin {
    function getFeeParameters() external view returns (JiblycoinStructs.FeeParameters memory feeParams);
}
