import "dotenv/config";

import "hardhat-deploy";

import { HardhatUserConfig, HttpNetworkAccountsUserConfig } from "hardhat/types";

import { getRpcURL } from "./utils/getRpcURL";
import { getVerifyConfig } from "./utils/getVerifyConfig";

const PRIVATE_KEY = process.env.PRIVATE_KEY;

if (!PRIVATE_KEY) {
  throw new Error(
    "Could not find MNEMONIC or PRIVATE_KEY environment variables. It will not be possible to execute transactions in your example.",
  );
}
const accounts: HttpNetworkAccountsUserConfig | undefined = [PRIVATE_KEY];

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.28",
        settings: {
          optimizer: {
            enabled: true,
            runs: 10_000,
          },
        },
      },
    ],
  },
  networks: {
    mainnet: {
      accounts,
      url: getRpcURL("mainnet"),
      verify: getVerifyConfig("mainnet"),
    },
    sepolia: {
      accounts,
      url: getRpcURL("sepolia"),
      verify: getVerifyConfig("sepolia"),
    },
    arbiSepolia: {
      accounts,
      url: getRpcURL("arbiSepolia"),
      verify: getVerifyConfig("arbiSepolia"),
    },
    polygon: {
      accounts,
      url: getRpcURL("polygon"),
      verify: getVerifyConfig("polygon"),
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
};

export default config;
