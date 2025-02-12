// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IChainlinkVRF {
    /**
     * @notice Requests randomness from the Chainlink VRF.
     * @param keyHash The key hash to identify the Chainlink VRF job.
     * @param fee The fee required for the request.
     * @return requestId A unique identifier for the randomness request.
     */
    function requestRandomness(bytes32 keyHash, uint256 fee) external returns (uint256 requestId);
}
