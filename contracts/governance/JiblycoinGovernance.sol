// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Import only DiamondStorageLib and Errors; note that DiamondStorageLib already imports JiblycoinStructs.
import "../libraries/DiamondStorageLib.sol";
import "../libraries/Errors.sol";
import "../core/JiblycoinCore.sol"; // Needed for inheritance

/**
 * @title JiblycoinGovernance
 * @notice Implements governance functionalities for Jiblycoin.
 * @dev Uses centralized storage (via DiamondStorageLib) to store governance parameters and proposals.
 *      The library "JiblycoinStructs" is already imported via DiamondStorageLib.
 */
abstract contract JiblycoinGovernance is JiblycoinCore {
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
    event JiblyPointsVestingInitialized(address indexed beneficiary, uint256 amount, uint64 vestingDuration, uint64 cliffDuration);

    uint64 public proposalCount;

    /**
     * @notice Initializes the governance module.
     * @param _governanceParams The governance parameters (defined in JiblycoinStructs).
     * @param _govPointsCaps The reward cap parameters.
     * @param _adminWallet The address to be assigned as admin.
     */
    function __JiblycoinGovernance_init(
        JiblycoinStructs.GovernanceParameters memory _governanceParams,
        JiblycoinStructs.RewardCapsStruct memory _govPointsCaps,
        address _adminWallet
    ) internal onlyInitializing {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
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
        if (bytes(description).length == 0) revert Errors.NoDescription();
        if (bytes(category).length == 0) revert Errors.NoCategory();
        if (executionTime == 0) revert Errors.ExecTimeZero();

        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        proposalCount++;
        // Use the Proposal type defined in JiblycoinStructs (imported via DiamondStorageLib)
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

    /**
     * @notice Casts a vote for a proposal.
     * @param proposalId The ID of the proposal to vote for.
     */
    function vote(uint64 proposalId) external nonReentrant whenNotPaused {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        JiblycoinStructs.Proposal storage prop = ds.proposals[proposalId];
        require(block.timestamp >= prop.startTime, "Vote not started");
        require(block.timestamp <= prop.endTime, "Vote ended");
        require(!prop.executed, "Already executed");
        if (balanceOf(msg.sender) < 1e18) revert Errors.InsufficientBalance();
        if (prop.voters[msg.sender]) revert Errors.AlreadyClaimed();
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
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        JiblycoinStructs.Proposal storage prop = ds.proposals[proposalId];
        require(block.timestamp > prop.endTime, "Voting not ended");
        require(!prop.executed, "Already executed");
        uint256 quorum = (totalSupply() * ds.governanceParams.quorumPercentage) / 10000;
        require(prop.voteCount >= quorum, "Quorum not met");
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
        if (delegatee == address(0)) revert Errors.ZeroAddress();
        if (delegatee == msg.sender) revert Errors.ZeroAddress();
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (balanceOf(msg.sender) < amount) revert Errors.InsufficientBalance();
        ds.delegations[msg.sender][delegatee] += amount;
        emit Delegated(msg.sender, delegatee, amount);
    }

    /**
     * @notice Revokes delegated voting power.
     * @param delegatee The delegatee address.
     * @param amount The amount of voting power to revoke.
     */
    function undelegate(address delegatee, uint256 amount) external nonReentrant whenNotPaused {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (ds.delegations[msg.sender][delegatee] < amount) revert Errors.InsufficientBalance();
        ds.delegations[msg.sender][delegatee] -= amount;
        emit DelegationRevoked(msg.sender, delegatee, amount);
    }
}
