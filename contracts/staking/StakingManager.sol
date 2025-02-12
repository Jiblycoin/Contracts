// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../core/JiblycoinCore.sol";
import "../libraries/DiamondStorageLib.sol";
import "../interfaces/IJiblycoinNFT.sol";
import "../interfaces/IJiblycoinOracle.sol";
import "../libraries/Errors.sol";
import "../structs/JiblycoinStructs.sol";

/**
 * @title StakingManager
 * @notice Manages staking pools and user staking operations for Jiblycoin.
 * @dev Extends JiblycoinCore and uses centralized storage via DiamondStorageLib.
 *      Provides functions for setting the oracle and NFT contract addresses, adding staking pools,
 *      adjusting reward rates, staking, unstaking, and claiming rewards.
 *      All functions are protected by non‑reentrancy and pausable checks and restricted by role-based access.
 */
contract StakingManager is JiblycoinCore {
    // ====================================================
    // Event Declarations
    // ====================================================
    /**
     * @notice Emitted when a new staking pool is added.
     * @param id The identifier of the staking pool.
     * @param name The name of the staking pool.
     * @param baseRewardRate The base reward rate for the pool.
     * @param exclusive Indicates whether the pool requires NFT holding.
     */
    event StakingPoolAdded(uint256 indexed id, string name, uint256 baseRewardRate, bool exclusive);

    /**
     * @notice Emitted when a pool's reward rate is adjusted.
     * @param poolId The identifier of the staking pool.
     * @param newRate The new reward rate set.
     */
    event RewardRateAdjusted(uint256 indexed poolId, uint256 newRate);

    /**
     * @notice Emitted when a user stakes tokens.
     * @param user The address of the staker.
     * @param amount The amount staked.
     * @param poolId The staking pool identifier.
     */
    event Staked(address indexed user, uint256 amount, uint256 poolId);

    /**
     * @notice Emitted when a user unstakes tokens.
     * @param user The address of the user.
     * @param amount The amount unstaked.
     * @param poolId The staking pool identifier.
     */
    event Unstaked(address indexed user, uint256 amount, uint256 poolId);

    /**
     * @notice Emitted when a user claims staking rewards.
     * @param user The address of the user.
     * @param reward The amount of rewards claimed.
     * @param poolId The staking pool identifier.
     */
    event RewardsClaimed(address indexed user, uint256 reward, uint256 poolId);

    /**
     * @notice Emitted when the reward for a staker in a pool is updated.
     * @param user The address of the staker.
     * @param poolId The staking pool identifier.
     * @param earned The amount of reward earned since the last update.
     */
    event RewardUpdated(address indexed user, uint256 indexed poolId, uint256 earned);

    // ====================================================
    // Administrative Functions
    // ====================================================
    /**
     * @notice Sets the oracle contract address used for adjusting reward rates.
     * @dev Only callable by an account with the ADMIN_ROLE.
     * @param _oracle The address of the oracle contract.
     */
    function setOracle(address _oracle) external onlyRole(ADMIN_ROLE) {
        require(_oracle != address(0), "Invalid oracle address");
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        ds.jiblycoinOracle = _oracle;
        emit OracleSet(_oracle);
    }

    /**
     * @notice Sets the NFT contract address used for verifying eligibility in exclusive staking pools.
     * @dev Only callable by an account with the ADMIN_ROLE.
     * @param _nftAddress The address of the NFT contract.
     */
    function setNFTContractAddress(address _nftAddress) external onlyRole(ADMIN_ROLE) {
        require(_nftAddress != address(0), "Zero address");
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        ds.nftContractAddress = _nftAddress;
    }

    /**
     * @notice Adds a new staking pool.
     * @dev Only callable by an account with the ADMIN_ROLE. Reverts if the pool already exists.
     * @param id The unique identifier for the staking pool.
     * @param name The name of the staking pool.
     * @param baseRewardRate The base reward rate for the pool.
     * @param exclusive Indicates if the pool is exclusive (requires NFT holding).
     */
    function addStakingPool(
        uint256 id,
        string memory name,
        uint256 baseRewardRate,
        bool exclusive
    ) external onlyRole(ADMIN_ROLE) {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        require(ds.stakingPools[id].id == 0, "Pool exists");
        ds.stakingPools[id] = JiblycoinStructs.StakingPool({
            id: id,
            name: name,
            baseRewardRate: baseRewardRate,
            exclusive: exclusive,
            currentRewardRate: baseRewardRate,
            totalStaked: 0
        });
        ds.poolIds.push(id);
        emit StakingPoolAdded(id, name, baseRewardRate, exclusive);
    }

    /**
     * @notice Adjusts the reward rate of an existing staking pool based on market conditions.
     * @dev Only callable by an account with the ADMIN_ROLE. Reverts if the pool does not exist or if the oracle is not set.
     * @param poolId The identifier of the staking pool.
     */
    function adjustPoolReward(uint256 poolId) external onlyRole(ADMIN_ROLE) {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        require(ds.stakingPools[poolId].id != 0, "Invalid pool");
        if (ds.jiblycoinOracle == address(0)) revert Errors.OracleNotSet();
        uint256 marketFactor = IJiblycoinOracle(ds.jiblycoinOracle).getMarketConditionFactor();
        uint256 newRate = (ds.stakingPools[poolId].baseRewardRate * marketFactor) / 10000;
        ds.stakingPools[poolId].currentRewardRate = newRate;
        emit RewardRateAdjusted(poolId, newRate);
    }

    // ====================================================
    // Staking Functions
    // ====================================================
    /**
     * @notice Stakes a specified amount of tokens into a staking pool.
     * @dev Requires a non-zero amount, a valid pool, and if exclusive, NFT ownership.
     * @param amount The amount of tokens to stake.
     * @param poolId The staking pool identifier.
     */
    function stake(uint256 amount, uint256 poolId) external whenNotPaused nonReentrant {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        require(amount > 0, "Cannot stake 0");
        require(ds.stakingPools[poolId].id != 0, "Invalid pool");
        if (ds.stakingPools[poolId].exclusive) {
            IJiblycoinNFT nftContract = IJiblycoinNFT(ds.nftContractAddress);
            require(nftContract.balanceOf(msg.sender) > 0, "Must hold NFT");
        }
        _updateRewards(poolId, msg.sender);
        _transfer(msg.sender, address(this), amount);
        ds.stakingPools[poolId].totalStaked += amount;
        ds.stakedAmounts[poolId][msg.sender] += amount;
        emit Staked(msg.sender, amount, poolId);
    }

    /**
     * @notice Unstakes a specified amount of tokens from a staking pool.
     * @dev Requires a non-zero amount, a valid pool, and sufficient staked balance.
     * @param amount The amount of tokens to unstake.
     * @param poolId The staking pool identifier.
     */
    function unstake(uint256 amount, uint256 poolId) external whenNotPaused nonReentrant {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        require(amount > 0, "Cannot unstake 0");
        require(ds.stakingPools[poolId].id != 0, "Invalid pool");
        require(ds.stakedAmounts[poolId][msg.sender] >= amount, "Too many tokens");
        _updateRewards(poolId, msg.sender);
        ds.stakedAmounts[poolId][msg.sender] -= amount;
        ds.stakingPools[poolId].totalStaked -= amount;
        _transfer(address(this), msg.sender, amount);
        emit Unstaked(msg.sender, amount, poolId);
    }

    /**
     * @notice Claims accumulated staking rewards from a staking pool.
     * @dev Requires that rewards are available and that the contract holds sufficient tokens to cover the reward.
     * @param poolId The staking pool identifier.
     */
    function claimRewards(uint256 poolId) external whenNotPaused nonReentrant {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        require(ds.stakingPools[poolId].id != 0, "Invalid pool");
        _updateRewards(poolId, msg.sender);
        uint256 reward = ds.rewardDebt[poolId][msg.sender];
        require(reward > 0, "No rewards");
        require(balanceOf(address(this)) >= reward, "Not enough tokens in contract");
        ds.rewardDebt[poolId][msg.sender] = 0;
        _transfer(address(this), msg.sender, reward);
        emit RewardsClaimed(msg.sender, reward, poolId);
    }

    // ====================================================
    // Internal Utility Functions
    // ====================================================
    /**
     * @notice Internal function to update staking rewards for a user in a specific pool.
     * @dev Calculates earned rewards based on staked amount, current reward rate, and time elapsed.
     * @param poolId The staking pool identifier.
     * @param user The address of the staker.
     */
    function _updateRewards(uint256 poolId, address user) internal {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        JiblycoinStructs.StakingPool storage pool = ds.stakingPools[poolId];
        uint256 stakedAmt = ds.stakedAmounts[poolId][user];
        if (stakedAmt == 0) return;
        uint256 currentTimestamp = block.timestamp;
        uint256 lastReward = ds.lastRewardTimestamp[user][poolId];
        if (lastReward == 0) {
            lastReward = ds.snapshotId;
        }
        uint256 timeElapsed = currentTimestamp - lastReward;
        if (timeElapsed > 0) {
            uint256 earned = (stakedAmt * pool.currentRewardRate * timeElapsed) / 1e4;
            ds.rewardDebt[poolId][user] += earned;
            ds.lastRewardTimestamp[user][poolId] = currentTimestamp;
            emit RewardUpdated(user, poolId, earned);
        }
    }
}
