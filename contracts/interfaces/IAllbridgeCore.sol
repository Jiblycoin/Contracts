// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title IAllbridgeCore
 * @notice Interface for the Allbridge Core contract used to facilitate cross-chain token transfers.
 * @dev Exposes a function to send tokens to a recipient on a different blockchain,
 *      including additional data if required. The function is payable to allow for native currency fees.
 */
interface IAllbridgeCore {
    /**
     * @notice Sends tokens to a recipient on a different blockchain.
     * @dev This function must be called with an appropriate payable value if required by the bridge.
     * @param amount The amount of tokens to transfer.
     * @param destinationChainId The identifier of the destination blockchain.
     * @param recipient The address of the recipient on the destination chain.
     * @param extraData Additional data needed for the transfer (e.g., routing or metadata).
     * @return transferId A unique identifier for the initiated cross-chain transfer.
     */
    function sendToChain(
        uint256 amount,
        uint256 destinationChainId,
        address recipient,
        bytes calldata extraData
    ) external payable returns (bytes32 transferId);
}
