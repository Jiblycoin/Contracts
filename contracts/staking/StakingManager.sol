// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../core/JiblycoinCore.sol";
import "../libraries/DiamondStorageLib.sol";
import "../interfaces/IJiblycoinNFT.sol";
import "../libraries/Errors.sol";
import "../structs/JiblycoinStructs.sol";

contract StakingManager is JiblycoinCore {
    // Events specific to staking operations.
    event StakingPoolAdded(uint256 indexed id, string name, uint256 baseRewardRate, bool exclusive);
    event RewardRateAdjusted(uint256 indexed poolId, uint256 newRate);
    event Staked(address indexed user, uint256 amount, uint256 poolId);
    event Unstaked(address indexed user, uint256 amount, uint256 poolId);
    event RewardsClaimed(address indexed user, uint256 reward, uint256 poolId);
    event RewardUpdated(address indexed user, uint256 indexed poolId, uint256 earned);

    // Note: Do not use 'override' here because we are not overriding any parent function.
    function setOracle(address _oracle) external onlyRole(ADMIN_ROLE) {
        require(_oracle != address(0), "Invalid oracle address");
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        ds.jiblycoinOracle = _oracle;
        // OracleSet is declared in the core contract.
        emit OracleSet(_oracle);
    }

    function setNFTContractAddress(address _nftAddress) external onlyRole(ADMIN_ROLE) {
        require(_nftAddress != address(0), "Zero address");
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

    function adjustPoolReward(uint256 poolId) external onlyRole(ADMIN_ROLE) {
        DiamondStorageLib.DiamondStorage storage ds = DiamondStorageLib.diamondStorage();
        require(ds.stakingPools[poolId].id != 0, "Invalid pool");
        if (ds.jiblycoinOracle == address(0)) revert Errors.OracleNotSet();
        uint256 marketFactor = IJiblycoinOracle(ds.jiblycoinOracle).getMarketConditionFactor();
        uint256 newRate = (ds.stakingPools[poolId].baseRewardRate * marketFactor) / 10000;
        ds.stakingPools[poolId].currentRewardRate = newRate;
        emit RewardRateAdjusted(poolId, newRate);
    }

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
