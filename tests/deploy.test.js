const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
// Import parseEther from ethers' utils directly:
const { parseEther } = require("ethers/lib/utils");

describe("JiblyCoin Deployment Test", function () {
  it("should deploy JiblyCoin as an upgradeable proxy and verify its address", async function () {
    // Define initial parameters
    const name = "JiblyCoin";
    const symbol = "JIBLY";

    const feeParams = {
      baseFeePercentage: 100,           // 1%
      redistributionFeePercentage: 200, // 2%
      burnFeePercentage: 100            // 1%
    };

    const txnParams = {
      maxTransactionSize: parseEther("1000"), // 1000 JIBLY
      maxGasLimit: 300000,                     // Example gas limit
      transactionCooldown: 60                  // 60 seconds
    };

    const govParams = {
      quorumPercentage: 2500,    // 25%
      minHoldingDuration: 604800, // 1 week (in seconds)
      votingRewardPercentage: 500// 5%
    };

    const referralParams = {
      referralRewards: [500, 300, 200],         // 5%, 3%, 2% for 3 levels
      referralRewardCap: parseEther("1000")      // 1000 JIBLY
    };

    const rewardCaps = {
      userRewardCap: parseEther("10000"),       // 10,000 JIBLY
      totalRewardCap: parseEther("1000000"),      // 1,000,000 JIBLY
      monthlyRewardCap: parseEther("83333")       // ~83,333 JIBLY
    };

    const quorumPercentage = govParams.quorumPercentage;
    const minHoldingDuration = govParams.minHoldingDuration;
    const votingRewardPercentage = govParams.votingRewardPercentage;
    const userRewardCap = rewardCaps.userRewardCap;
    const redistributionPool = rewardCaps.totalRewardCap;
    const upgradeDelay = 86400; // 1 day in seconds

    // Define the locker address (Admin Wallet)
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

    // Basic check: verify the deployed address is valid.
    expect(jiblyCoin.address).to.properAddress;
  });
});
