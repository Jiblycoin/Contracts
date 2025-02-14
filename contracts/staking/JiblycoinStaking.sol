// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Import only necessary symbols.
import { JiblycoinCore } from "../core/JiblycoinCore.sol";
import { JiblycoinStructs } from "../structs/JiblycoinStructs.sol";
import { DiamondStorageLib } from "../libraries/DiamondStorageLib.sol";
import { Errors } from "../libraries/Errors.sol";
import { IJiblycoinNFT } from "../interfaces/IJiblycoinNFT.sol";
// Removed unused import of IJiblycoinOracle

/**
 * @title JiblycoinStaking
 * @notice Implements staking functionality for Jiblycoin.
 */
abstract contract JiblycoinStaking is JiblycoinCore {
    // Mapping from pool ID to staking pool details.
    mapping(uint256 => JiblycoinStructs.StakingPool) public stakingPools;

    // Array of staking pool IDs.
    uint256[] public poolIds;

    // Mapping from pool ID to staked amounts per user.
    mapping(uint256 => mapping(address => uint256)) public stakedAmounts;

    // Mapping from pool ID to accrued reward debt per user.
    mapping(uint256 => mapping(address => uint256)) public rewardDebt;

    // Mapping from user address and pool ID to the last reward timestamp.
    mapping(address => mapping(uint256 => uint256)) public lastRewardTimestamp;

    event StakingPoolAdded(uint256 indexed id, string name, uint256 baseRewardRate, bool exclusive);
    event RewardRateAdjusted(uint256 indexed poolId, uint256 newRate);
    event Staked(address indexed user, uint256 amount, uint256 poolId);
    event Unstaked(address indexed user, uint256 amount, uint256 poolId);
    event RewardsClaimed(address indexed user, uint256 reward, uint256 poolId);
    event RewardUpdated(address indexed user, uint256 indexed poolId, uint256 earned);

    /**
     * @notice Internal initializer for staking logic.
     * @dev Intentionally left blank.
     */
    // solhint-disable-next-line no-empty-blocks
    function __jiblycoinStakingInit() internal onlyInitializing { }

    /**
     * @notice Adds a new staking pool.
     * @param id The unique pool identifier.
     * @param name The descriptive name of the pool.
     * @param baseRewardRate The base reward rate.
     * @param exclusive Whether the pool requires NFT ownership.
     */
    function addStakingPool(
        uint256 id,
        string memory name,
        uint256 baseRewardRate,
        bool exclusive
    ) external onlyRole(ADMIN_ROLE) {
        if (stakingPools[id].id != 0) revert Errors.PoolAlreadyExists();
        stakingPools[id] = JiblycoinStructs.StakingPool({
            id: id,
            name: name,
            baseRewardRate: baseRewardRate,
            exclusive: exclusive,
            currentRewardRate: baseRewardRate,
            totalStaked: 0
        });
        poolIds.push(id);
        emit StakingPoolAdded(id, name, baseRewardRate, exclusive);
    }

    /**
     * @notice Adjusts the reward rate for a given staking pool based on market conditions.
     * @param poolId The pool identifier.
     */
    function adjustPoolReward(uint256 poolId) external onlyRole(ADMIN_ROLE) {
        if (stakingPools[poolId].id == 0) revert Errors.PoolDoesNotExist();
        if (address(jiblycoinOracle) == address(0)) revert Errors.OracleNotSet();
        // jiblycoinOracle is inherited from JiblycoinCore
        uint256 marketFactor = jiblycoinOracle.getMarketConditionFactor();
        uint256 newRate = (stakingPools[poolId].baseRewardRate * marketFactor) / 10000;
        stakingPools[poolId].currentRewardRate = newRate;
        emit RewardRateAdjusted(poolId, newRate);
    }

    /**
     * @notice Sets the NFT contract address used for exclusive staking pools.
     * @param _nftAddress The address of the NFT contract.
     */
    function setNFTContractAddress(address _nftAddress) external virtual onlyRole(ADMIN_ROLE) {
        if (_nftAddress == address(0)) revert Errors.ZeroAddress();
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        ds.nftContractAddress = _nftAddress;
    }

    /**
     * @notice Retrieves the NFT contract address.
     * @return The NFT contract address.
     */
    function _getNFTContractAddress() internal view virtual returns (address) {
        return DiamondStorageLib.diamondStorage().nftContractAddress;
    }

    /**
     * @notice Stakes a specified amount of tokens into a pool.
     * @param amount The amount of tokens to stake.
     * @param poolId The identifier of the staking pool.
     */
    function stake(uint256 amount, uint256 poolId) external whenNotPaused nonReentrant {
        if (amount == 0) revert Errors.CannotStakeZero();
        if (stakingPools[poolId].id == 0) revert Errors.PoolDoesNotExist();
        if (stakingPools[poolId].exclusive) {
            IJiblycoinNFT nftContract = IJiblycoinNFT(_getNFTContractAddress());
            if (nftContract.balanceOf(msg.sender) == 0) revert Errors.MustHoldNFT();
        }
        _updateRewards(poolId, msg.sender);
        _transfer(msg.sender, address(this), amount);
        stakingPools[poolId].totalStaked += amount;
        stakedAmounts[poolId][msg.sender] += amount;
        emit Staked(msg.sender, amount, poolId);
    }

    /**
     * @notice Unstakes a specified amount of tokens from a pool.
     * @param amount The amount of tokens to unstake.
     * @param poolId The identifier of the staking pool.
     */
    function unstake(uint256 amount, uint256 poolId) external whenNotPaused nonReentrant {
        if (amount == 0) revert Errors.CannotStakeZero();
        if (stakingPools[poolId].id == 0) revert Errors.PoolDoesNotExist();
        if (stakedAmounts[poolId][msg.sender] < amount) revert Errors.InsufficientStakedBalance();
        _updateRewards(poolId, msg.sender);
        stakedAmounts[poolId][msg.sender] -= amount;
        stakingPools[poolId].totalStaked -= amount;
        _transfer(address(this), msg.sender, amount);
        emit Unstaked(msg.sender, amount, poolId);
    }

    /**
     * @notice Claims accumulated staking rewards from a pool.
     * @param poolId The identifier of the staking pool.
     */
    function claimRewards(uint256 poolId) external whenNotPaused nonReentrant {
        if (stakingPools[poolId].id == 0) revert Errors.PoolDoesNotExist();
        _updateRewards(poolId, msg.sender);
        uint256 reward = rewardDebt[poolId][msg.sender];
        if (reward == 0) revert Errors.AlreadyClaimed();
        if (balanceOf(address(this)) < reward) revert Errors.InsufficientBalance();
        rewardDebt[poolId][msg.sender] = 0;
        _transfer(address(this), msg.sender, reward);
        emit RewardsClaimed(msg.sender, reward, poolId);
    }

    /**
     * @notice Internal function to update the rewards for a given user and pool.
     * @param poolId The staking pool identifier.
     * @param user The address of the user.
     */
    function _updateRewards(uint256 poolId, address user) internal {
        uint256 stakedAmt = stakedAmounts[poolId][user];
        if (stakedAmt == 0) return;
        uint256 currentTimestamp = block.timestamp;
        uint256 lastReward = lastRewardTimestamp[user][poolId];
        if (lastReward == 0) {
            // Initialize lastReward with snapshotId if not set
            lastReward = snapshotId;
        }
        uint256 timeElapsed = currentTimestamp - lastReward;
        if (timeElapsed > 0) {
            uint256 earned = (stakedAmt * stakingPools[poolId].currentRewardRate * timeElapsed) / 1e4;
            rewardDebt[poolId][user] += earned;
            lastRewardTimestamp[user][poolId] = currentTimestamp;
            emit RewardUpdated(user, poolId, earned);
        }
    }

    uint256[50] private __gap;
}
