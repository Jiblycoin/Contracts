// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

library VotingLib {
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        bool executed;
    }

    function createProposal(Proposal storage self, uint256 id, string memory description) internal {
        self.id = id;
        self.description = description;
        self.voteCount = 0;
        self.executed = false;
    }

    function vote(Proposal storage self) internal {
        self.voteCount += 1;
    }

    function execute(Proposal storage self) internal {
        self.executed = true;
    }
    
    function computeVotePower(
        uint256 balance,
        uint256, // unused
        uint256  // unused
    ) internal pure returns (uint256 votePower) {
        votePower = sqrt(balance);
    }

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
