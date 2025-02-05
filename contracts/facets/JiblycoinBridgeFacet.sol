// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../core/JiblycoinCore.sol";
import "../interfaces/IAllbridgeCore.sol";

/**
 * @title JiblycoinBridgeFacet
 * @dev Provides functions to initiate cross-chain transfers via Allbridge Core.
 */
contract JiblycoinBridgeFacet is JiblycoinCore {
    IAllbridgeCore public allbridgeCore;

    event AllbridgeCoreAddressSet(address indexed newAddress);
    event CrossChainTransferInitiated(
        bytes32 transferId,
        uint256 amount,
        uint256 destinationChainId,
        address recipient
    );

    function setAllbridgeCoreAddress(address _bridgeAddress) external onlyRole(ADMIN_ROLE) {
        require(_bridgeAddress != address(0), "Invalid address");
        allbridgeCore = IAllbridgeCore(_bridgeAddress);
        emit AllbridgeCoreAddressSet(_bridgeAddress);
    }

    function sendTokensCrossChain(
        uint256 amount,
        uint256 destinationChainId,
        address recipient,
        bytes calldata extraData
    ) external payable onlyRole(ADMIN_ROLE) returns (bytes32 transferId) {
        require(amount > 0, "Amount must be > 0");
        require(recipient != address(0), "Invalid recipient");
        transferId = allbridgeCore.sendToChain{value: msg.value}(amount, destinationChainId, recipient, extraData);
        emit CrossChainTransferInitiated(transferId, amount, destinationChainId, recipient);
    }
}
