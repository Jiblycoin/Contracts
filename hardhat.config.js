require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");

module.exports = {
  solidity: {
    version: "0.8.27", // Matches your Solidity version
    settings: {
      optimizer: {
        enabled: true,
        runs: 300, // Lower runs value may reduce deployed size further. Experiment with values (e.g., 100 or 150) instead of 300.
      },
      viaIR: true, // Enable the IR pipeline to optimize stack usage and contract size
      metadata: {
        // Remove extra metadata to help reduce size if needed.
        useLiteralContent: false,
      },
    },
  },
  networks: {
    hardhat: {
      forking: {
        url: process.env.MAINNET_RPC || "", // Optional: Fork mainnet for testing
        blockNumber: process.env.FORK_BLOCK_NUMBER ? parseInt(process.env.FORK_BLOCK_NUMBER) : undefined,
      },
    },
    bscTestnet: {
      url: process.env.BSC_TESTNET_RPC || "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
    bscMainnet: {
      url: process.env.BSC_MAINNET_RPC || "https://bsc-dataseed.binance.org/",
      chainId: 56,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
    ethereumMainnet: {
      url: process.env.ETHEREUM_RPC || "https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID",
      chainId: 1,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
  },
  etherscan: {
    apiKey: {
      bsc: process.env.BSCSCAN_API_KEY,
      // ethereum: process.env.ETHERSCAN_API_KEY, // Uncomment if needed
      // polygon: process.env.POLYGONSCAN_API_KEY, // Uncomment if needed
    },
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    gasPrice: 21,
    coinmarketcap: process.env.COINMARKETCAP_API_KEY || "",
    token: "BNB",
  },
  mocha: {
    timeout: 200000,
  },
  paths: {
    sources: "./contracts",     // Default source folder
    tests: "./tests",           // Default test folder
    cache: "./cache",           // Default cache folder
    artifacts: "./artifacts",   // Default artifacts folder
  },
};
