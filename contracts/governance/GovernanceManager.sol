// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinGovernance } from "../governance/JiblycoinGovernance.sol";
import { DiamondStorageLib } from "../libraries/DiamondStorageLib.sol";
import { Errors } from "../libraries/Errors.sol";
import { JiblycoinStructs } from "../structs/JiblycoinStructs.sol";

contract GovernanceManager is JiblycoinGovernance {
    /**
     * @notice Executes a categorized proposal after voting has ended.
     * @dev Reverts if the voting period is not over, if the proposal is already executed, or if the quorum is not met.
     *      Additional logic based on the proposal category can be added.
     * @param proposalId The ID of the proposal to execute.
     */
    function executeCategorizedProposal(uint64 proposalId) external nonReentrant whenNotPaused {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        JiblycoinStructs.Proposal storage prop = ds.proposals[proposalId];

        if (block.timestamp <= prop.endTime) revert Errors.ExecTimeZero(); // Voting period not ended.
        if (prop.executed) revert Errors.AlreadyClaimed(); // Already executed.

        uint256 quorumValue = (totalSupply() * ds.governanceParams.quorumPercentage) / 10000;
        if (prop.voteCount < quorumValue) revert Errors.InsufficientBalance(); // Quorum not met.

        prop.executed = true;

        if (keccak256(bytes(prop.category)) == keccak256(bytes("Fee Adjustment"))) {
            // Fee adjustment logic not implemented.
            { uint256 _noop = 0; _noop = _noop; }
        } else if (keccak256(bytes(prop.category)) == keccak256(bytes("New Feature"))) {
            // New feature logic not implemented.
            { uint256 _noop = 0; _noop = _noop; }
        }
        
        emit ProposalExecuted(proposalId);
    }
}
