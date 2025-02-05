// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./diamond/JiblycoinDiamond.sol";

contract Jiblycoin is JiblycoinDiamond {
    constructor(address _admin, bytes memory _initCalldata) JiblycoinDiamond(_admin, _initCalldata) {
        // Additional constructor logic (if needed)
    }
}
