// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Use a named import with an alias for the diamond contract
import { JiblycoinDiamond as DiamondContract } from "./diamond/JiblycoinDiamond.sol";

contract Jiblycoin is DiamondContract {
    constructor(address _admin, bytes memory _initCalldata)
        DiamondContract(_admin, _initCalldata)
    {
        // Additional constructor logic (if needed)
    }
}
