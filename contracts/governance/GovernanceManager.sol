// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./JiblycoinGovernance.sol";
import "../libraries/DiamondStorageLib.sol";
import "../structs/JiblycoinStructs.sol";
import "../libraries/Errors.sol";

contract GovernanceManager is JiblycoinGovernance {
    /**
     * @notice Executes a categorized proposal after voting has ended.
     * @param proposalId The ID of the proposal.
     */
    function executeCategorizedProposal(uint64 proposalId) external nonReentrant whenNotPaused {
        // Get the Diamond storage
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        // Use the Proposal stored in DiamondStorage (of type JiblycoinStructs.Proposal)
        JiblycoinStructs.Proposal storage prop = ds.proposals[proposalId];
        require(block.timestamp > prop.endTime, "Voting not ended");
        require(!prop.executed, "Already executed");
        // Use the governance parameters from storage
        uint256 quorumValue = (totalSupply() * ds.governanceParams.quorumPercentage) / 10000;
        require(prop.voteCount >= quorumValue, "Quorum not met");
        prop.executed = true;
        
        // Execute based on proposal category.
        if (keccak256(bytes(prop.category)) == keccak256(bytes("Fee Adjustment"))) {
            // Implement fee adjustment logic here.
        } else if (keccak256(bytes(prop.category)) == keccak256(bytes("New Feature"))) {
            // Implement new feature logic here.
        }
        emit ProposalExecuted(proposalId);
    }
}
