// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IAllbridgeCore {
    function sendToChain(
        uint256 amount,
        uint256 destinationChainId,
        address recipient,
        bytes calldata extraData
    ) external payable returns (bytes32 transferId);
}
