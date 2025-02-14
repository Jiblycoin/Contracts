// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinCore } from "../core/JiblycoinCore.sol";
import { DiamondStorageLib } from "../libraries/DiamondStorageLib.sol";
import { Errors } from "../libraries/Errors.sol";
import { JiblycoinStructs } from "../structs/JiblycoinStructs.sol";

// Custom errors for governance actions
error VoteNotStarted();
error VoteEnded();
error ProposalAlreadyExecuted();
error VotingNotEnded();
error QuorumNotMet();

contract JiblycoinGovernanceFacet is JiblycoinCore {
    using DiamondStorageLib for DiamondStorageLib.DiamondStorage;

    event ProposalCreated(
        uint64 indexed id,
        string description,
        string category,
        address indexed proposer,
        uint64 executionTime
    );
    event Voted(address indexed voter, uint64 indexed proposalId, uint256 votingPower);
    event ProposalExecuted(uint64 indexed id);
    event Delegated(address indexed delegator, address indexed delegatee, uint256 amount);
    event DelegationRevoked(address indexed delegator, address indexed delegatee, uint256 amount);
    event GovernanceInitialized(
        JiblycoinStructs.GovernanceParameters governanceParams,
        JiblycoinStructs.RewardCapsStruct govPointsCaps,
        address adminWallet
    );

    uint64 public proposalCount;

    // Mixed-case initializer function
    function __jiblycoinGovernanceInit(
        JiblycoinStructs.GovernanceParameters memory _governanceParams,
        JiblycoinStructs.RewardCapsStruct memory _govPointsCaps,
        address _adminWallet
    ) internal onlyInitializing {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        ds.governanceParams.quorumPercentage = _governanceParams.quorumPercentage;
        ds.governanceParams.minHoldingDuration = _governanceParams.minHoldingDuration;
        ds.governanceParams.votingRewardPercentage = _governanceParams.votingRewardPercentage;

        ds.govPointsCaps.userPointsCap = _govPointsCaps.userPointsCap;
        ds.govPointsCaps.totalPointsCap = _govPointsCaps.totalPointsCap;
        ds.govPointsCaps.monthlyPointsCap = _govPointsCaps.monthlyPointsCap;

        _setupRole(DEFAULT_ADMIN_ROLE, _adminWallet);
        emit GovernanceInitialized(ds.governanceParams, ds.govPointsCaps, _adminWallet);
    }

    function createProposal(
        string memory description,
        string memory category,
        uint64 executionTime
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (bytes(description).length == 0) revert Errors.NoDescription();
        if (bytes(category).length == 0) revert Errors.NoCategory();
        if (executionTime == 0) revert Errors.ExecTimeZero();

        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        proposalCount++;
        JiblycoinStructs.Proposal storage newProp = ds.proposals[proposalCount];
        newProp.id = proposalCount;
        newProp.description = description;
        newProp.category = category;
        newProp.proposer = msg.sender;
        newProp.voteCount = 0;
        newProp.startTime = block.timestamp;
        newProp.endTime = block.timestamp + executionTime;
        newProp.executed = false;

        emit ProposalCreated(proposalCount, description, category, msg.sender, executionTime);
    }

    function vote(uint64 proposalId) external nonReentrant whenNotPaused {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        JiblycoinStructs.Proposal storage prop = ds.proposals[proposalId];
        if (block.timestamp < prop.startTime) revert VoteNotStarted();
        if (block.timestamp > prop.endTime) revert VoteEnded();
        if (prop.executed) revert ProposalAlreadyExecuted();
        if (balanceOf(msg.sender) < 1e18) revert Errors.InsufficientBalance();
        if (prop.voters[msg.sender]) revert Errors.AlreadyClaimed();
        uint256 votingPower = balanceOf(msg.sender);
        prop.voters[msg.sender] = true;
        prop.voteCount += votingPower;
        emit Voted(msg.sender, proposalId, votingPower);
    }

    function executeProposal(uint64 proposalId) external nonReentrant whenNotPaused {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        JiblycoinStructs.Proposal storage prop = ds.proposals[proposalId];
        if (block.timestamp <= prop.endTime) revert VotingNotEnded();
        if (prop.executed) revert ProposalAlreadyExecuted();
        uint256 quorum = (totalSupply() * ds.governanceParams.quorumPercentage) / 10000;
        if (prop.voteCount < quorum) revert QuorumNotMet();
        prop.executed = true;
        emit ProposalExecuted(proposalId);
    }

    function getDelegatee(address) external pure returns (address) {
        return address(0);
    }

    function delegate(address delegatee, uint256 amount) external nonReentrant whenNotPaused {
        if (delegatee == address(0)) revert Errors.ZeroAddress();
        if (delegatee == msg.sender) revert Errors.ZeroAddress();
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (balanceOf(msg.sender) < amount) revert Errors.InsufficientBalance();
        ds.delegations[msg.sender][delegatee] += amount;
        emit Delegated(msg.sender, delegatee, amount);
    }

    function undelegate(address delegatee, uint256 amount) external nonReentrant whenNotPaused {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (ds.delegations[msg.sender][delegatee] < amount) revert Errors.InsufficientBalance();
        ds.delegations[msg.sender][delegatee] -= amount;
        emit DelegationRevoked(msg.sender, delegatee, amount);
    }
}
