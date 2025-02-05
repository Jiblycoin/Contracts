// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { JiblycoinCore } from "../core/JiblycoinCore.sol";
import { JiblycoinStructs } from "../structs/JiblycoinStructs.sol";
import { DiamondStorageLib } from "../libraries/DiamondStorageLib.sol";
import { Errors } from "../libraries/Errors.sol";
import { IJiblycoinOracle } from "../interfaces/IJiblycoinOracle.sol";
import { IJiblycoinNFT } from "../interfaces/IJiblycoinNFT.sol";

error CannotStakeZero();
error PoolDoesNotExist();
error InsufficientStakedBalance();
error MustHoldNFT();

abstract contract JiblycoinStaking is JiblycoinCore {
    mapping(uint256 => JiblycoinStructs.StakingPool) public stakingPools;
    uint256[] public poolIds;
    mapping(uint256 => mapping(address => uint256)) public stakedAmounts;
    mapping(uint256 => mapping(address => uint256)) public rewardDebt;
    mapping(address => mapping(uint256 => uint256)) public lastRewardTimestamp;

    event StakingPoolAdded(uint256 indexed id, string name, uint256 baseRewardRate, bool exclusive);
    event RewardRateAdjusted(uint256 indexed poolId, uint256 newRate);
    event Staked(address indexed user, uint256 amount, uint256 poolId);
    event Unstaked(address indexed user, uint256 amount, uint256 poolId);
    event RewardsClaimed(address indexed user, uint256 reward, uint256 poolId);
    event RewardUpdated(address indexed user, uint256 indexed poolId, uint256 earned);

    function __JiblycoinStaking_init() internal onlyInitializing {
        // Additional staking initialization logic if needed.
    }

    function addStakingPool(
        uint256 id,
        string memory name,
        uint256 baseRewardRate,
        bool exclusive
    ) external onlyRole(ADMIN_ROLE) {
        if (stakingPools[id].id != 0) revert PoolDoesNotExist();
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

    function adjustPoolReward(uint256 poolId) external onlyRole(ADMIN_ROLE) {
        if (stakingPools[poolId].id == 0) revert PoolDoesNotExist();
        if (address(jiblycoinOracle) == address(0)) revert Errors.OracleNotSet();
        uint256 marketFactor = IJiblycoinOracle(jiblycoinOracle).getMarketConditionFactor();
        uint256 newRate = (stakingPools[poolId].baseRewardRate * marketFactor) / 10000;
        stakingPools[poolId].currentRewardRate = newRate;
        emit RewardRateAdjusted(poolId, newRate);
    }

    function setNFTContractAddress(address _nftAddress) external virtual onlyRole(ADMIN_ROLE) {
        if (_nftAddress == address(0)) revert Errors.ZeroAddress();
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        ds.nftContractAddress = _nftAddress;
    }

    function _getNFTContractAddress() internal view virtual returns (address) {
        return DiamondStorageLib.diamondStorage().nftContractAddress;
    }

    function stake(uint256 amount, uint256 poolId) external whenNotPaused nonReentrant {
        if (amount == 0) revert CannotStakeZero();
        if (stakingPools[poolId].id == 0) revert PoolDoesNotExist();

        if (stakingPools[poolId].exclusive) {
            IJiblycoinNFT nftContract = IJiblycoinNFT(_getNFTContractAddress());
            if (nftContract.balanceOf(msg.sender) == 0) revert MustHoldNFT();
        }

        _updateRewards(poolId, msg.sender);
        _transfer(msg.sender, address(this), amount);
        stakingPools[poolId].totalStaked += amount;
        stakedAmounts[poolId][msg.sender] += amount;
        emit Staked(msg.sender, amount, poolId);
    }

    function unstake(uint256 amount, uint256 poolId) external whenNotPaused nonReentrant {
        if (amount == 0) revert CannotStakeZero();
        if (stakingPools[poolId].id == 0) revert PoolDoesNotExist();
        if (stakedAmounts[poolId][msg.sender] < amount) revert InsufficientStakedBalance();
        _updateRewards(poolId, msg.sender);
        stakedAmounts[poolId][msg.sender] -= amount;
        stakingPools[poolId].totalStaked -= amount;
        _transfer(address(this), msg.sender, amount);
        emit Unstaked(msg.sender, amount, poolId);
    }

    function claimRewards(uint256 poolId) external whenNotPaused nonReentrant {
        if (stakingPools[poolId].id == 0) revert PoolDoesNotExist();
        _updateRewards(poolId, msg.sender);
        uint256 reward = rewardDebt[poolId][msg.sender];
        if (reward == 0) revert Errors.AlreadyClaimed();
        if (balanceOf(address(this)) < reward) revert Errors.InsufficientBalance();
        rewardDebt[poolId][msg.sender] = 0;
        _transfer(address(this), msg.sender, reward);
        emit RewardsClaimed(msg.sender, reward, poolId);
    }

    function _updateRewards(uint256 poolId, address user) internal {
        uint256 stakedAmt = stakedAmounts[poolId][user];
        if (stakedAmt == 0) return;
        uint256 currentTimestamp = block.timestamp;
        uint256 lastReward = lastRewardTimestamp[user][poolId];
        if (lastReward == 0) {
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
