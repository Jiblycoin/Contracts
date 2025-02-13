// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../governance/JiblycoinGovernance.sol";
import "../libraries/DiamondStorageLib.sol";
import "../structs/JiblycoinStructs.sol";
import "../libraries/Errors.sol";

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

        // Ensure the voting period has ended.
        if (block.timestamp <= prop.endTime) revert Errors.ExecTimeZero(); // Voting period not ended.
        // Ensure the proposal has not already been executed.
        if (prop.executed) revert Errors.AlreadyClaimed(); // Already executed.
        
        // Calculate the quorum requirement.
        uint256 quorumValue = (totalSupply() * ds.governanceParams.quorumPercentage) / 10000;
        if (prop.voteCount < quorumValue) revert Errors.InsufficientBalance(); // Quorum not met.
        
        // Mark the proposal as executed.
        prop.executed = true;
        
        // Execute additional logic based on proposal category.
        if (keccak256(bytes(prop.category)) == keccak256(bytes("Fee Adjustment"))) {
            // Implement fee adjustment logic here.
        } else if (keccak256(bytes(prop.category)) == keccak256(bytes("New Feature"))) {
            // Implement new feature logic here.
        }
        
        emit ProposalExecuted(proposalId);
    }
}
