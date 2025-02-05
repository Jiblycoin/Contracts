// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { Initializable }         from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ERC20Upgradeable }       from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { PausableUpgradeable }    from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { UUPSUpgradeable }        from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import { FeeLibrary as FeeLib }   from "../libraries/FeeLibrary.sol";
import { JiblycoinUtils }         from "../utils/JiblycoinUtils.sol";
import { JiblycoinStructs as JStructs } from "../structs/JiblycoinStructs.sol";
import { IJiblycoinOracle }       from "../interfaces/IJiblycoinOracle.sol";
import { Errors }               from "../libraries/Errors.sol";
import { DiamondStorageLib }    from "../libraries/DiamondStorageLib.sol";

/// @dev Interface for Chainlink VRF (simplified)
interface IChainlinkVRF {
    function requestRandomness(bytes32 keyHash, uint256 fee) external returns (uint256 requestId);
}

/**
 * @title JiblycoinCore
 * @notice Core ERC20 implementation for Jiblycoin with upgradeability, meta‑transactions,
 * dynamic fee adjustments, secure randomness via Chainlink VRF, timelock governance,
 * analytics, and bonus mechanisms for long‑term holders.
 *
 * @dev This contract is designed to be the shared “heart” of a diamond pattern architecture.
 */
abstract contract JiblycoinCore is
    Initializable,
    ERC20Upgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    using FeeLib for JStructs.FeeParameters;
    using JiblycoinUtils for uint256;

    // ====================================================
    // Role Constants
    // ====================================================
    bytes32 public constant ADMIN_ROLE    = keccak256("ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant SECURITY_ROLE = keccak256("SECURITY_ROLE");
    bytes32 public constant BRIDGE_ROLE   = keccak256("BRIDGE_ROLE");

    // ====================================================
    // Event Declarations
    // ====================================================
    event OracleSet(address indexed oracleAddr);
    event JiblyPointsBurned(address indexed user, uint256 amount);
    event SnapshotTaken(uint256 indexed blockNumber);
    event MonthlyBurnBuybackTriggered(address indexed caller, uint256 burnAmount, uint256 buybackAmount);
    event MetaTransactionExecuted(address indexed user, address indexed relayer, bytes functionSignature);
    event RandomRewardRequested(uint256 requestId);
    event GasIncentiveClaimed(address indexed user, uint256 bonusAmount);
    event LongTermBonusClaimed(address indexed user, uint256 bonusAmount);
    event AnalyticsUpdated(uint256 totalFees, uint256 totalBurned, uint256 totalBuyback);
    event FeeParametersUpdated(JStructs.FeeParameters feeParams);

    // ====================================================
    // Constants
    // ====================================================
    uint256 public constant INITIAL_SUPPLY = 10_000_000 * 10**18;
    uint256 public constant BASE_MULTIPLIER  = 1e18;   // 1x
    uint256 public constant MAX_MULTIPLIER   = 2e18;   // 2x
    uint256 public constant MULTIPLIER_PERIOD = 30 days;

    // ====================================================
    // Grouped Addresses
    // ====================================================
    address public mainWallet;
    address public adminWallet;
    address public devWallet;
    address public rewardsAirdrop;
    address public collaborationMarketing;
    address public burnAddress;
    address public buybackWallet;

    // ====================================================
    // Grouped Booleans
    // ====================================================
    bool public circuitBreakerActive;
    bool public monthlyBurnBuybackAllowed;

    // ====================================================
    // Other Numeric Variables
    // ====================================================
    uint256 public marketConditionFactor;
    uint256 public maxWalletSize;
    uint256 public maxTransactionSize;
    uint256 public monthlyBurnThreshold;
    uint256 public monthlyBuybackThreshold;
    uint256 public lastMonthlyActionTimestamp;
    uint256 public snapshotId;
    uint256 public totalFeesCollected;
    uint256 public totalBurned;
    uint256 public totalBuyback;

    // ====================================================
    // Mappings
    // ====================================================
    mapping(address => bool) public blacklistedAddresses;
    mapping(address => uint256) public lastTransferTime;
    mapping(address => uint256) public feeRebateBP;

    // ====================================================
    // External Contract Addresses & Fee/Bridge Structures
    // ====================================================
    IJiblycoinOracle public jiblycoinOracle;
    JStructs.BridgeParameters public bridgeParams;
    JStructs.FeeParameters public feeParams;

    // ====================================================
    // EIP-712 Domain Separator for Meta-Transactions
    // ====================================================
    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant META_TRANSACTION_TYPEHASH = keccak256("MetaTransaction(uint256 nonce,address from,bytes functionSignature)");
    mapping(address => uint256) public nonces;

    // ====================================================
    // Timelock for Critical Functions (Upgrade Governance)
    // ====================================================
    uint256 public upgradeTimelock;
    uint256 public constant TIMELOCK_DELAY = 1 days;

    // ====================================================
    // Chainlink VRF Parameters
    // ====================================================
    IChainlinkVRF public vrfCoordinator;
    bytes32 public vrfKeyHash;
    uint256 public vrfFee;

    // ====================================================
    // Incentive Pools
    // ====================================================
    uint256 public gasIncentivePool;
    uint256 public longTermBonusPool;

    // ====================================================
    // INITIALIZER FUNCTION
    // ====================================================
    /**
     * @notice Initializes the core contract.
     */
    function __JiblycoinCore_init(
        string memory name_,
        string memory symbol_,
        JStructs.FeeParameters memory _feeParams,
        address _adminWallet,
        address _mainWallet,
        address _devWallet,
        address _rewardsAirdrop,
        address _collaborationMarketing,
        address _burnAddress,
        address _buybackWallet,
        JStructs.BridgeParameters memory _bridgeParams,
        address _vrfCoordinator,
        bytes32 _vrfKeyHash,
        uint256 _vrfFee
    ) internal onlyInitializing {
        __ERC20_init(name_, symbol_);
        __AccessControl_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();

        // Set up roles
        _setupRole(DEFAULT_ADMIN_ROLE, _adminWallet);
        _setupRole(ADMIN_ROLE, _adminWallet);
        _setupRole(UPGRADER_ROLE, _adminWallet);
        _setupRole(SECURITY_ROLE, _adminWallet);
        _setupRole(BRIDGE_ROLE, _bridgeParams.bridgeContract);

        // Set addresses
        mainWallet = _mainWallet;
        adminWallet = _adminWallet;
        devWallet = _devWallet;
        rewardsAirdrop = _rewardsAirdrop;
        collaborationMarketing = _collaborationMarketing;
        burnAddress = _burnAddress;
        buybackWallet = _buybackWallet;
        bridgeParams = _bridgeParams;

        // Set fee parameters
        feeParams = _feeParams;

        // Mint and allocate initial supply
        _mint(address(this), INITIAL_SUPPLY);
        _allocateInitialSupply();

        // Set anti‑whale limits
        maxWalletSize = (INITIAL_SUPPLY * 5) / 100;
        maxTransactionSize = (INITIAL_SUPPLY * 1) / 1000;
        marketConditionFactor = 100;
        monthlyBurnBuybackAllowed = false;
        monthlyBurnThreshold = 0;
        monthlyBuybackThreshold = 0;
        lastMonthlyActionTimestamp = block.timestamp;
        snapshotId = 0;

        // Initialize EIP‑712 Domain Separator
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name_)),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );

        // Set upgrade timelock
        upgradeTimelock = block.timestamp + TIMELOCK_DELAY;

        // Set Chainlink VRF parameters
        vrfCoordinator = IChainlinkVRF(_vrfCoordinator);
        vrfKeyHash = _vrfKeyHash;
        vrfFee = _vrfFee;

        // Initialize incentive pools (1% each of INITIAL_SUPPLY)
        gasIncentivePool = (INITIAL_SUPPLY * 1) / 100;
        longTermBonusPool = (INITIAL_SUPPLY * 1) / 100;
    }

    // ====================================================
    // Internal Utility Functions
    // ====================================================
    function _allocateInitialSupply() internal {
        unchecked {
            uint256 devAllocation = (INITIAL_SUPPLY * 15) / 100;
            uint256 rewardsAirdropAllocation = (INITIAL_SUPPLY * 10) / 100;
            uint256 collaborationMarketingAllocation = (INITIAL_SUPPLY * 5) / 100;
            uint256 burnAllocation = (INITIAL_SUPPLY * 5) / 100;
            uint256 buybackAllocation = (INITIAL_SUPPLY * 5) / 100;
            uint256 adminAllocation = (INITIAL_SUPPLY * 5) / 100;

            _transfer(address(this), devWallet, devAllocation);
            _transfer(address(this), rewardsAirdrop, rewardsAirdropAllocation);
            _transfer(address(this), collaborationMarketing, collaborationMarketingAllocation);
            _transfer(address(this), burnAddress, burnAllocation);
            _transfer(address(this), buybackWallet, buybackAllocation);
            _transfer(address(this), adminWallet, adminAllocation);
        }
    }

    // ====================================================
    // EIP‑712 Meta-Transaction Execution
    // ====================================================
    function executeMetaTransaction(
        address user,
        bytes memory functionSignature,
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS
    ) public payable returns (bytes memory) {
        uint256 userNonce = nonces[user];
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(META_TRANSACTION_TYPEHASH, userNonce, user, keccak256(functionSignature)))
            )
        );
        require(user == ecrecover(digest, sigV, sigR, sigS), "Invalid signature");
        nonces[user] = userNonce + 1;

        (bool success, bytes memory returnData) = address(this).call(abi.encodePacked(functionSignature, user));
        require(success, "Function call not successful");
        emit MetaTransactionExecuted(user, msg.sender, functionSignature);
        return returnData;
    }

    // ====================================================
    // Upgrade with Timelock
    // ====================================================
    function upgradeNow(address newImplementation) external onlyRole(UPGRADER_ROLE) nonReentrant {
        require(block.timestamp >= upgradeTimelock, "Upgrade timelock not passed");
        _authorizeUpgrade(newImplementation);
        _upgradeTo(newImplementation);
        upgradeTimelock = block.timestamp + TIMELOCK_DELAY;
    }

    // ====================================================
    // Dynamic Fee Parameters Update
    // ====================================================
    function updateFeeParameters(JStructs.FeeParameters memory newFeeParams) external onlyRole(ADMIN_ROLE) {
        feeParams = newFeeParams;
        emit FeeParametersUpdated(newFeeParams);
    }

    // ====================================================
    // Analytics Function
    // ====================================================
    function getAnalyticsData() external view returns (
        uint256 _totalFeesCollected,
        uint256 _totalBurned,
        uint256 _totalBuyback,
        uint256 _gasIncentivePool,
        uint256 _longTermBonusPool
    ) {
        return (totalFeesCollected, totalBurned, totalBuyback, gasIncentivePool, longTermBonusPool);
    }

    // ====================================================
    // Chainlink VRF Randomness Request
    // ====================================================
    function requestRandomReward() external returns (uint256 requestId) {
        requestId = vrfCoordinator.requestRandomness(vrfKeyHash, vrfFee);
        emit RandomRewardRequested(requestId);
    }

    // ====================================================
    // Incentive Mechanisms
    // ====================================================
    function claimGasIncentive() external nonReentrant {
        uint256 heldTime = block.timestamp - lastTransferTime[msg.sender];
        uint256 bonus = (heldTime / 1 days) * 1e16; // Example: 0.01% bonus per day
        require(bonus > 0, "No incentive available");
        require(gasIncentivePool >= bonus, "Insufficient incentive pool");
        gasIncentivePool -= bonus;
        _transfer(address(this), msg.sender, bonus);
        emit GasIncentiveClaimed(msg.sender, bonus);
    }

    function claimLongTermBonus() external nonReentrant {
        uint256 heldTime = block.timestamp - lastTransferTime[msg.sender];
        require(heldTime >= 90 days, "Holding period too short for bonus");
        uint256 bonusDays = (heldTime - 90 days) / 1 days;
        uint256 bonus = (balanceOf(msg.sender) * bonusDays * 5) / 100000; // Example: 0.005% bonus per day
        require(bonus > 0, "No bonus calculated");
        require(longTermBonusPool >= bonus, "Insufficient bonus pool");
        longTermBonusPool -= bonus;
        _transfer(address(this), msg.sender, bonus);
        emit LongTermBonusClaimed(msg.sender, bonus);
    }

    // ====================================================
    // Overridden Transfer & Fee Distribution
    // ====================================================
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        if (circuitBreakerActive) revert Errors.CircuitActive();
        if (blacklistedAddresses[from] || blacklistedAddresses[to]) revert Errors.Blacklisted();
        super._beforeTokenTransfer(from, to, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override nonReentrant {
        if (amount > maxTransactionSize) revert Errors.TxExceedsMax();
        if (balanceOf(recipient) + amount > maxWalletSize) revert Errors.WalletExceedsMax();

        uint256 totalFee = feeParams.calculateTotalFee(amount, marketConditionFactor);
        uint256 afterFee = amount - totalFee;

        lastTransferTime[sender] = block.timestamp;
        lastTransferTime[recipient] = block.timestamp;
        totalFeesCollected += totalFee;

        _distributeFees(sender, totalFee);
        super._transfer(sender, recipient, afterFee);
    }

    function _distributeFees(address sender, uint256 totalFee) internal {
        uint256 baseF = (totalFee * feeParams.baseFeePercentage) / 10000;
        uint256 redisF = (totalFee * feeParams.redistributionFeePercentage) / 10000;
        uint256 burnF = (totalFee * feeParams.burnFeePercentage) / 10000;
        uint256 buybackF = (totalFee * feeParams.buybackFeePercentage) / 10000;
        uint256 jiblyHoodF = (totalFee * feeParams.jiblyHoodFeePercentage) / 10000;

        if (baseF > 0) super._transfer(sender, mainWallet, baseF);
        if (redisF > 0) super._transfer(sender, address(this), redisF);
        if (burnF > 0) {
            super._transfer(sender, burnAddress, burnF);
            totalBurned += burnF;
        }
        if (buybackF > 0) {
            super._transfer(sender, buybackWallet, buybackF);
            totalBuyback += buybackF;
        }
        if (jiblyHoodF > 0) {
            DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
            ds.jiblyHoodPool += jiblyHoodF;
        }
    }

    // ====================================================
    // Utility: Holding Multiplier Calculation
    // ====================================================
    function getHoldingMultiplier(address holder) public view returns (uint256 multiplier) {
        uint256 heldTime = block.timestamp - lastTransferTime[holder];
        uint256 periods = heldTime / MULTIPLIER_PERIOD;
        uint256 bonus = periods * 1e16;
        unchecked {
            if (bonus + BASE_MULTIPLIER > MAX_MULTIPLIER) {
                multiplier = MAX_MULTIPLIER;
            } else {
                multiplier = BASE_MULTIPLIER + bonus;
            }
        }
    }

    // ====================================================
    // Upgrade Authorization
    // ====================================================
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}

    uint256[50] private __gap;
}
