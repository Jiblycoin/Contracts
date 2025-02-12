// scripts/deploy.js

// Import necessary modules and Hardhat plugins
const { ethers, upgrades } = require("hardhat");
const { parseEther } = require("ethers/lib/utils");

async function main() {
  // Define initial token parameters
  const name = "JiblyCoin";
  const symbol = "JIBLY";

  // Define fee parameters (in basis points)
  const feeParams = {
    baseFeePercentage: 100,           // 1%
    redistributionFeePercentage: 200, // 2%
    burnFeePercentage: 100,           // 1%
    buybackFeePercentage: 100,        // 1%
    jiblyHoodFeePercentage: 50        // 0.5%
  };

  // Define transaction parameters (example values)
  const txnParams = {
    maxTransactionSize: parseEther("1000"), // Maximum 1000 JIBLY per transaction
    maxGasLimit: 300000,                     // Example gas limit
    transactionCooldown: 60                  // 60 seconds cooldown between transactions
  };

  // Define governance parameters
  const govParams = {
    quorumPercentage: 2500,     // 25% quorum required (in basis points)
    minHoldingDuration: 604800, // 1 week in seconds
    votingRewardPercentage: 500 // 5% reward for voting (in basis points)
  };

  // Define referral parameters
  const referralParams = {
    referralRewards: [500, 300, 200],         // Referral rewards for 3 levels: 5%, 3%, 2%
    referralRewardCap: parseEther("1000")      // Maximum referral reward of 1000 JIBLY
  };

  // Define reward caps for loyalty/points
  const rewardCaps = {
    userRewardCap: parseEther("10000"),       // Maximum 10,000 JIBLY per user
    totalRewardCap: parseEther("1000000"),      // Maximum 1,000,000 JIBLY in total distribution
    monthlyRewardCap: parseEther("83333")       // Approximately 83,333 JIBLY monthly cap
  };

  // Additional parameters extracted from governance parameters and reward caps
  const quorumPercentage = govParams.quorumPercentage;
  const minHoldingDuration = govParams.minHoldingDuration;
  const votingRewardPercentage = govParams.votingRewardPercentage;
  const userRewardCap = rewardCaps.userRewardCap;
  const redistributionPool = rewardCaps.totalRewardCap;
  const upgradeDelay = 86400; // 1 day in seconds

  // Define the locker address (Admin Wallet) - example address
  const locker = "0x1E885Cf6B4bdb0161632493328066a79d04527cb";

  console.log("Getting contract factory for JiblyCoin...");
  const JiblyCoin = await ethers.getContractFactory("JiblyCoin");

  console.log("Deploying JiblyCoin as an upgradeable proxy...");
  const jiblyCoin = await upgrades.deployProxy(
    JiblyCoin,
    [
      name,
      symbol,
      feeParams,
      txnParams,
      govParams,
      referralParams,
      rewardCaps,
      quorumPercentage,
      minHoldingDuration,
      votingRewardPercentage,
      userRewardCap,
      redistributionPool,
      upgradeDelay,
      locker
    ],
    { initializer: "initialize" }
  );

  console.log("Awaiting JiblyCoin deployment...");
  await jiblyCoin.deployed();

  console.log("JiblyCoin deployed at:", jiblyCoin.address);
}

// Execute the main deployment function and handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Deployment error:", error);
    process.exit(1);
  });
