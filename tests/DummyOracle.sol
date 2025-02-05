// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract DummyOracle {
    uint256 private factor;
    constructor(uint256 _factor) {
        factor = _factor;
    }
    function getMarketConditionFactor() external view returns (uint256) {
        return factor;
    }
}
