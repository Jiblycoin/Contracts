// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Bind the core and Allbridge interface into namespaces
import * as Core from "../core/JiblycoinCore.sol";
import * as IAllbridge from "../interfaces/IAllbridgeCore.sol";
import { Errors } from "../libraries/Errors.sol";

/**
 * @title JiblycoinBridgeFacet
 * @notice Facilitates cross-chain token transfers using the Allbridge Core protocol.
 * @dev Extends JiblycoinCore to leverage centralized storage and governance controls.
 *      Includes detailed NatSpec documentation, custom error checks, and event emissions.
 */
contract JiblycoinBridgeFacet is Core.JiblycoinCore {
    /// @notice Allbridge Core contract instance used for cross-chain transfers.
    IAllbridge.IAllbridgeCore public allbridgeCore;

    /**
     * @notice Emitted when the Allbridge Core contract address is updated.
     * @param newAddress The new Allbridge Core contract address.
     */
    event AllbridgeCoreAddressSet(address indexed newAddress);

    /**
     * @notice Emitted when a cross-chain transfer is initiated.
     * @param transferId The unique identifier of the transfer.
     * @param amount The amount of tokens transferred.
     * @param destinationChainId The ID of the destination blockchain.
     * @param recipient The address receiving tokens on the destination chain.
     */
    event CrossChainTransferInitiated(
        bytes32 transferId,
        uint256 amount,
        uint256 destinationChainId,
        address recipient
    );

    /**
     * @notice Sets the Allbridge Core contract address.
     * @dev Only callable by an account with the ADMIN_ROLE.
     * @param _bridgeAddress The address of the Allbridge Core contract.
     */
    function setAllbridgeCoreAddress(address _bridgeAddress) external onlyRole(ADMIN_ROLE) {
        if (_bridgeAddress == address(0)) revert Errors.ZeroAddress();
        allbridgeCore = IAllbridge.IAllbridgeCore(_bridgeAddress);
        emit AllbridgeCoreAddressSet(_bridgeAddress);
    }

    /**
     * @notice Initiates a cross-chain token transfer via Allbridge.
     * @dev Only callable by an account with the ADMIN_ROLE.
     *      Reverts if the transfer amount is zero or if the recipient address is invalid.
     * @param amount The amount of tokens to transfer.
     * @param destinationChainId The chain ID of the destination blockchain.
     * @param recipient The address on the destination chain that will receive the tokens.
     * @param extraData Additional data required by the bridge protocol.
     * @return transferId The unique identifier for the initiated transfer.
     */
    function sendTokensCrossChain(
        uint256 amount,
        uint256 destinationChainId,
        address recipient,
        bytes calldata extraData
    ) external payable onlyRole(ADMIN_ROLE) returns (bytes32 transferId) {
        if (amount == 0) revert Errors.InsufficientBalance(); // Using InsufficientBalance as proxy for zero amount
        if (recipient == address(0)) revert Errors.ZeroAddress();
        transferId = allbridgeCore.sendToChain{value: msg.value}(amount, destinationChainId, recipient, extraData);
        emit CrossChainTransferInitiated(transferId, amount, destinationChainId, recipient);
    }
}
