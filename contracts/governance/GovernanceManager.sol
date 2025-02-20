// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinGovernance } from "../governance/JiblycoinGovernance.sol";
import { DiamondStorageLib } from "../libraries/DiamondStorageLib.sol";
import { JiblycoinStructs as JStructs } from "../structs/JiblycoinStructs.sol";

// Custom errors for governance operations
error VoteNotStarted();
error VoteEnded();
error ProposalAlreadyExecuted();
error VoteNotEnded();
error QuorumNotMet();
error InvalidProposalId();

contract GovernanceManager is JiblycoinGovernance {
    /**
     * @notice Executes a categorized proposal after voting has ended.
     * @dev Reverts if the voting period is not over, if the proposal is already executed, or if the quorum is not met.
     *      Additional logic based on the proposal category can be added.
     * @param proposalId The ID of the proposal to execute.
     */
    function executeCategorizedProposal(uint64 proposalId) external nonReentrant whenNotPaused {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (proposalId == 0 || proposalId > proposalCount) revert InvalidProposalId();
        JStructs.Proposal storage prop = ds.proposals[proposalId];

        if (block.timestamp <= prop.endTime) revert VoteNotEnded();
        if (prop.executed) revert ProposalAlreadyExecuted();
        
        uint256 quorumValue = (totalSupply() * ds.governanceParams.quorumPercentage) / 10000;
        if (prop.voteCount < quorumValue) revert QuorumNotMet();

        // Mark the proposal as executed
        prop.executed = true;

        // Categorized execution logic (placeholders for future implementation)
        if (keccak256(bytes(prop.category)) == keccak256(bytes("Fee Adjustment"))) {
            // Fee adjustment logic goes here.
        } else if (keccak256(bytes(prop.category)) == keccak256(bytes("New Feature"))) {
            // New feature logic goes here.
        }
        
        emit ProposalExecuted(proposalId);
    }
}
