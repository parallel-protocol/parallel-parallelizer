import "dotenv/config";
import "hardhat-deploy";
import "@nomicfoundation/hardhat-foundry";

import { HardhatUserConfig, HttpNetworkAccountsUserConfig } from "hardhat/types";

import { getRpcURL } from "./utils/getRpcURL";
import { getVerifyConfig } from "./utils/getVerifyConfig";

const accounts: HttpNetworkAccountsUserConfig | undefined = process.env.PRIVATE_KEY
  ? [process.env.PRIVATE_KEY]
  : undefined;

if (!accounts) {
  throw new Error(
    "Could not find PRIVATE_KEY environment variables. It will not be possible to execute transactions in your example.",
  );
}

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.28",
        settings: {
          evmVersion: "cancun",
          optimizer: {
            enabled: true,
            runs: 1_000,
          },
          viaIR: true,
        },
      },
    ],
  },
  networks: {
    mainnet: {
      url: getRpcURL("mainnet"),
      verify: getVerifyConfig("mainnet"),
      accounts,
    },
    sepolia: {
      url: getRpcURL("sepolia"),
      verify: getVerifyConfig("sepolia"),
      accounts,
    },
    polygon: {
      url: getRpcURL("polygon"),
      verify: getVerifyConfig("polygon"),
      accounts,
    },
    arbiSepolia: {
      url: getRpcURL("arbiSepolia"),
      verify: getVerifyConfig("arbiSepolia"),
      accounts,
    },
    optimism: {
      url: getRpcURL("optimism"),
      verify: getVerifyConfig("optimism"),
      accounts,
    },
    base: {
      url: getRpcURL("base"),
      verify: getVerifyConfig("base"),
      accounts,
    },
    arbitrum: {
      url: getRpcURL("arbitrum"),
      verify: getVerifyConfig("arbitrum"),
      accounts,
    },
    sonic: {
      url: getRpcURL("sonic"),
      verify: getVerifyConfig("sonic"),
      accounts,
    },
    sei: {
      url: getRpcURL("sei"),
      verify: getVerifyConfig("sei"),
      accounts,
    },
    avalanche: {
      url: getRpcURL("avalanche"),
      verify: getVerifyConfig("avalanche"),
      accounts,
    },
    bsc: {
      url: getRpcURL("bsc"),
      verify: getVerifyConfig("bsc"),
      accounts,
    },
    berachain: {
      url: getRpcURL("berachain"),
      verify: getVerifyConfig("berachain"),
      accounts,
    },
    scroll: {
      url: getRpcURL("scroll"),
      verify: getVerifyConfig("scroll"),
      accounts,
    },
    mantle: {
      url: getRpcURL("mantle"),
      verify: getVerifyConfig("mantle"),
      accounts,
    },
    gnosis: {
      url: getRpcURL("gnosis"),
      verify: getVerifyConfig("gnosis"),
      accounts,
    },
    unichain: {
      url: getRpcURL("unichain"),
      verify: getVerifyConfig("unichain"),
      accounts,
    },
    ink: {
      url: getRpcURL("ink"),
      verify: getVerifyConfig("ink"),
      accounts,
    },
    hyperevm: {
      url: getRpcURL("hyperevm"),
      verify: getVerifyConfig("hyperevm"),
      accounts,
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
};

export default config;
