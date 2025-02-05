// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IJiblycoinOracle {
    function getMarketConditionFactor() external view returns (uint256 marketConditionFactor);
}
