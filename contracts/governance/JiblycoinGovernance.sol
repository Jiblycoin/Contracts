// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// solhint-disable func-name-mixedcase

// Use named imports with aliases to avoid global imports.
import { DiamondStorageLib as DS } from "../libraries/DiamondStorageLib.sol";
import { Errors as Err } from "../libraries/Errors.sol";
import { JiblycoinCore } from "../core/JiblycoinCore.sol";
import { JiblycoinStructs as JStructs } from "../structs/JiblycoinStructs.sol";

// Define custom errors to replace require statements.
error VoteNotStarted();
error VoteEnded();
error ProposalAlreadyExecuted();
error VoteNotEnded();
error QuorumNotMet();

/**
 * @title JiblycoinGovernance
 * @notice Implements governance functionalities for Jiblycoin.
 * @dev Uses centralized storage (via DS) to store governance parameters and proposals.
 *      The library JiblycoinStructs is imported via DS.
 */
abstract contract JiblycoinGovernance is JiblycoinCore {
    using DS for DS.DiamondStorage;

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
    event JiblyPointsVestingInitialized(
        address indexed beneficiary,
        uint256 amount,
        uint64 vestingDuration,
        uint64 cliffDuration
    );

    uint64 public proposalCount;

    /**
     * @notice Initializes the governance module.
     * @param _governanceParams The governance parameters (defined in JStructs).
     * @param _govPointsCaps The reward cap parameters.
     * @param _adminWallet The address to be assigned as admin.
     */
    function initializeGovernance(
        JStructs.GovernanceParameters memory _governanceParams,
        JStructs.RewardCapsStruct memory _govPointsCaps,
        address _adminWallet
    ) internal onlyInitializing {
        DS.DiamondStorage storage ds = DS.diamondStorage();
        ds.governanceParams = _governanceParams;
        ds.govPointsCaps = _govPointsCaps;
        _setupRole(DEFAULT_ADMIN_ROLE, _adminWallet);
    }

    /**
     * @notice Creates a new governance proposal.
     * @param description A text description of the proposal.
     * @param category The category of the proposal.
     * @param executionTime The duration for which voting is open.
     */
    function createProposal(
        string memory description,
        string memory category,
        uint64 executionTime
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (bytes(description).length == 0) revert Err.NoDescription();
        if (bytes(category).length == 0) revert Err.NoCategory();
        if (executionTime == 0) revert Err.ExecTimeZero();

        DS.DiamondStorage storage ds = DS.diamondStorage();
        proposalCount++;
        JStructs.Proposal storage newProp = ds.proposals[proposalCount];
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

    /**
     * @notice Casts a vote for a proposal.
     * @param proposalId The ID of the proposal to vote for.
     */
    function vote(uint64 proposalId) external nonReentrant whenNotPaused {
        DS.DiamondStorage storage ds = DS.diamondStorage();
        JStructs.Proposal storage prop = ds.proposals[proposalId];
        if (block.timestamp < prop.startTime) revert VoteNotStarted();
        if (block.timestamp > prop.endTime) revert VoteEnded();
        if (prop.executed) revert ProposalAlreadyExecuted();
        if (balanceOf(msg.sender) < 1e18) revert Err.InsufficientBalance();
        if (prop.voters[msg.sender]) revert Err.AlreadyClaimed();
        uint256 votingPower = balanceOf(msg.sender);
        prop.voters[msg.sender] = true;
        prop.voteCount += votingPower;
        emit Voted(msg.sender, proposalId, votingPower);
    }

    /**
     * @notice Executes a proposal once its voting period has ended and quorum is met.
     * @param proposalId The ID of the proposal to execute.
     */
    function executeProposal(uint64 proposalId) external nonReentrant whenNotPaused {
        DS.DiamondStorage storage ds = DS.diamondStorage();
        JStructs.Proposal storage prop = ds.proposals[proposalId];
        if (block.timestamp <= prop.endTime) revert VoteNotEnded();
        if (prop.executed) revert ProposalAlreadyExecuted();
        uint256 quorum = (totalSupply() * ds.governanceParams.quorumPercentage) / 10000;
        if (prop.voteCount < quorum) revert QuorumNotMet();
        prop.executed = true;
        emit ProposalExecuted(proposalId);
    }

    /**
     * @notice Returns the delegatee for a given address.
     * @dev Currently returns the zero address as delegation is not implemented.
     */
    function getDelegatee(address) external pure returns (address) {
        return address(0);
    }

    /**
     * @notice Delegates voting power to another address.
     * @param delegatee The address to delegate to.
     * @param amount The amount of voting power to delegate.
     */
    function delegate(address delegatee, uint256 amount) external nonReentrant whenNotPaused {
        if (delegatee == address(0)) revert Err.ZeroAddress();
        if (delegatee == msg.sender) revert Err.ZeroAddress();
        DS.DiamondStorage storage ds = DS.diamondStorage();
        if (balanceOf(msg.sender) < amount) revert Err.InsufficientBalance();
        ds.delegations[msg.sender][delegatee] += amount;
        emit Delegated(msg.sender, delegatee, amount);
    }

    /**
     * @notice Revokes delegated voting power.
     * @param delegatee The delegatee address.
     * @param amount The amount of voting power to revoke.
     */
    function undelegate(address delegatee, uint256 amount) external nonReentrant whenNotPaused {
        DS.DiamondStorage storage ds = DS.diamondStorage();
        if (ds.delegations[msg.sender][delegatee] < amount) revert Err.InsufficientBalance();
        ds.delegations[msg.sender][delegatee] -= amount;
        emit DelegationRevoked(msg.sender, delegatee, amount);
    }
}
