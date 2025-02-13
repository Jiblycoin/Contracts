// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Import only necessary symbols to avoid global imports
import { JiblycoinCore } from "../core/JiblycoinCore.sol";
import { DiamondStorageLib } from "../libraries/DiamondStorageLib.sol";
import { IJiblycoinNFT } from "../interfaces/IJiblycoinNFT.sol";
import { IJiblycoinOracle } from "../interfaces/IJiblycoinOracle.sol";
import { Errors } from "../libraries/Errors.sol";
import { JiblycoinStructs } from "../structs/JiblycoinStructs.sol";

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
    event StakingPoolAdded(uint256 indexed id, string name, uint256 baseRewardRate, bool exclusive);
    event RewardRateAdjusted(uint256 indexed poolId, uint256 newRate);
    event Staked(address indexed user, uint256 amount, uint256 poolId);
    event Unstaked(address indexed user, uint256 amount, uint256 poolId);
    event RewardsClaimed(address indexed user, uint256 reward, uint256 poolId);
    event RewardUpdated(address indexed user, uint256 indexed poolId, uint256 earned);

    // ====================================================
    // Administrative Functions
    // ====================================================
    function setOracle(address _oracle) external onlyRole(ADMIN_ROLE) {
        if (_oracle == address(0)) revert Errors.ZeroAddress();
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        ds.jiblycoinOracle = _oracle;
        emit OracleSet(_oracle);
    }

    function setNFTContractAddress(address _nftAddress) external onlyRole(ADMIN_ROLE) {
        if (_nftAddress == address(0)) revert Errors.ZeroAddress();
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        ds.nftContractAddress = _nftAddress;
    }

    function addStakingPool(
        uint256 id,
        string memory name,
        uint256 baseRewardRate,
        bool exclusive
    ) external onlyRole(ADMIN_ROLE) {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (ds.stakingPools[id].id != 0) revert Errors.PoolAlreadyExists();
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

    function adjustPoolReward(uint256 poolId) external onlyRole(ADMIN_ROLE) {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (ds.stakingPools[poolId].id == 0) revert Errors.PoolDoesNotExist();
        if (ds.jiblycoinOracle == address(0)) revert Errors.OracleNotSet();
        uint256 marketFactor = IJiblycoinOracle(ds.jiblycoinOracle).getMarketConditionFactor();
        uint256 newRate = (ds.stakingPools[poolId].baseRewardRate * marketFactor) / 10000;
        ds.stakingPools[poolId].currentRewardRate = newRate;
        emit RewardRateAdjusted(poolId, newRate);
    }

    // ====================================================
    // Staking Functions
    // ====================================================
    function stake(uint256 amount, uint256 poolId) external whenNotPaused nonReentrant {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (amount == 0) revert Errors.CannotStakeZero();
        if (ds.stakingPools[poolId].id == 0) revert Errors.PoolDoesNotExist();
        if (ds.stakingPools[poolId].exclusive) {
            IJiblycoinNFT nftContract = IJiblycoinNFT(ds.nftContractAddress);
            if (nftContract.balanceOf(msg.sender) == 0) revert Errors.MustHoldNFT();
        }
        _updateRewards(poolId, msg.sender);
        _transfer(msg.sender, address(this), amount);
        ds.stakingPools[poolId].totalStaked += amount;
        ds.stakedAmounts[poolId][msg.sender] += amount;
        emit Staked(msg.sender, amount, poolId);
    }

    function unstake(uint256 amount, uint256 poolId) external whenNotPaused nonReentrant {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (amount == 0) revert Errors.CannotStakeZero();
        if (ds.stakingPools[poolId].id == 0) revert Errors.PoolDoesNotExist();
        if (ds.stakedAmounts[poolId][msg.sender] < amount) revert Errors.InsufficientStakedBalance();
        _updateRewards(poolId, msg.sender);
        ds.stakedAmounts[poolId][msg.sender] -= amount;
        ds.stakingPools[poolId].totalStaked -= amount;
        _transfer(address(this), msg.sender, amount);
        emit Unstaked(msg.sender, amount, poolId);
    }

    function claimRewards(uint256 poolId) external whenNotPaused nonReentrant {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        if (ds.stakingPools[poolId].id == 0) revert Errors.PoolDoesNotExist();
        _updateRewards(poolId, msg.sender);
        uint256 reward = ds.rewardDebt[poolId][msg.sender];
        if (reward == 0) revert Errors.InsufficientBalance();
        if (balanceOf(address(this)) < reward) revert Errors.InsufficientBalance();
        ds.rewardDebt[poolId][msg.sender] = 0;
        _transfer(address(this), msg.sender, reward);
        emit RewardsClaimed(msg.sender, reward, poolId);
    }

    // ====================================================
    // Internal Utility Functions
    // ====================================================
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
