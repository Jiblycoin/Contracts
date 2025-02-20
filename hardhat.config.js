require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");

// If you want to fork from BSC Mainnet, use its RPC URL and set a block number below 10,000.
// Otherwise, forkingConfig will be undefined.
const forkingConfig = process.env.BSC_MAINNET_RPC
  ? {
      url: process.env.BSC_MAINNET_RPC,
      blockNumber: process.env.FORK_BLOCK_NUMBER
        ? parseInt(process.env.FORK_BLOCK_NUMBER)
        : 5000, // default block number for forking (adjust as needed)
    }
  : undefined;

module.exports = {
  solidity: {
    version: "0.8.27",
    settings: {
      optimizer: {
        enabled: true,
        runs: 300, // adjust as needed
      },
      viaIR: true, // enable the IR pipeline to optimize stack usage and contract size
      metadata: {
        useLiteralContent: false, // remove extra metadata to reduce size if needed
      },
    },
  },
  networks: {
    hardhat: {
      // This will fork from BSC if forkingConfig is defined
      forking: forkingConfig,
    },
    bscTestnet: {
      url:
        process.env.BSC_TESTNET_RPC ||
        "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
    bscMainnet: {
      url:
        process.env.BSC_MAINNET_RPC ||
        "https://bsc-dataseed.binance.org/",
      chainId: 56,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
    ethereumMainnet: {
      url:
        process.env.ETHEREUM_RPC ||
        "https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID",
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
    sources: "./contracts", // Default source folder
    tests: "./tests", // Default test folder
    cache: "./cache", // Default cache folder
    artifacts: "./artifacts", // Default artifacts folder
  },
};
