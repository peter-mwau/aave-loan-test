require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
      accounts: [process.env.PRIVATE_KEY]
    },
    sepolia: {
      url: process.env.INFURA_RPC_URL,
      accounts: [process.env.PRIVATE_KEY]
    },
    monad: {
      url: "https://rpc.monad.xyz",
      accounts: [process.env.PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  }
};
