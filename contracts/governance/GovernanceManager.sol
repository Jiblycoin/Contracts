// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../governance/JiblycoinGovernance.sol";
import "../libraries/DiamondStorageLib.sol";
import "../structs/JiblycoinStructs.sol";
import "../libraries/Errors.sol";

/**
 * @title GovernanceManager
 * @notice Manages the execution of categorized governance proposals for Jiblycoin.
 * @dev Extends JiblycoinGovernance and leverages centralized storage via DiamondStorageLib.
 *      This contract ensures proposals are executed only after the voting period has ended and quorum is met.
 *      Detailed NatSpec documentation, non‑reentrancy, and pausable checks are integrated.
 */
contract GovernanceManager is JiblycoinGovernance {
    /**
     * @notice Executes a categorized proposal after voting has ended.
     * @dev Reverts if voting is still ongoing, if the proposal has already been executed, or if quorum is not met.
     *      Based on the proposal category, additional logic can be implemented.
     * @param proposalId The ID of the proposal to execute.
     */
    function executeCategorizedProposal(uint64 proposalId) external nonReentrant whenNotPaused {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        JiblycoinStructs.Proposal storage prop = ds.proposals[proposalId];

        require(block.timestamp > prop.endTime, "Voting not ended");
        require(!prop.executed, "Already executed");

        // Calculate the quorum requirement based on total supply and governance parameters.
        uint256 quorumValue = (totalSupply() * ds.governanceParams.quorumPercentage) / 10000;
        require(prop.voteCount >= quorumValue, "Quorum not met");

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
