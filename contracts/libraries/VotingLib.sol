// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library VotingLib {
    /**
     * @notice Structure representing a proposal for internal storage.
     * @dev Contains the proposal id, description, vote count, and executed status.
     */
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        bool executed;
    }

    /**
     * @notice Initializes a proposal with a given id and description.
     * @dev Sets the vote count to zero and marks the proposal as not executed.
     * @param self The proposal storage pointer.
     * @param id The unique identifier for the proposal.
     * @param description The text describing the proposal.
     */
    function createProposal(Proposal storage self, uint256 id, string memory description) internal {
        self.id = id;
        self.description = description;
        self.voteCount = 0;
        self.executed = false;
    }

    /**
     * @notice Casts a vote for the proposal by incrementing its vote count.
     * @param self The proposal storage pointer.
     */
    function vote(Proposal storage self) internal {
        self.voteCount += 1;
    }

    /**
     * @notice Marks the proposal as executed.
     * @param self The proposal storage pointer.
     */
    function execute(Proposal storage self) internal {
        self.executed = true;
    }
    
    /**
     * @notice Computes the voting power based on the provided token balance.
     * @dev Uses the Babylonian method to compute the square root.
     * @param balance The token balance used to determine voting power.
     * @return votePower The computed voting power.
     */
    function computeVotePower(
        uint256 balance,
        uint256, // unused parameter
        uint256  // unused parameter
    ) internal pure returns (uint256 votePower) {
        votePower = sqrt(balance);
    }

    /**
     * @notice Computes the integer square root of a given number.
     * @dev Implements the Babylonian method for computing square roots.
     * @param x The number for which the square root is calculated.
     * @return y The integer square root of x.
     */
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
