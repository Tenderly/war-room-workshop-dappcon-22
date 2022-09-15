require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-truffle5");
require("@openzeppelin/hardhat-upgrades");
const tenderly = require("@tenderly/hardhat-tenderly");
tenderly.setup({ automaticVerifications: true });
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// fresh mnemonic, never used for anything
// TODO: initalize them with whatever you would like
let mnemonic =
  "glad grant holiday attend figure reveal trial famous device type loyal jacket";

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.9",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.5.5",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.5.10",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },

  networks: {
    hardhat: {
      // forking: {
      //   url: "https://polygon-rpc.com",
      // },
      accounts: { mnemonic: mnemonic },
    },
    // TODO: configure your networks
    mainnet: {
      url: "https://polygon-rpc.com",
      accounts: { mnemonic: mnemonic },
      gasPrice: 139000000000,
    },
    ropsten: {
      url: "CHANGE ME",
      accounts: ["CHANGE ME"],
    },
    tenderly: {
      url: "CHANGE ME",
      chainId: 1,
    },
  },
  mocha: {
    timeout: 200000,
  },
  tenderly: {
    project: "CHANGE ME",
    username: "CHANGE ME",
    privateVerification: true,
  },
};
