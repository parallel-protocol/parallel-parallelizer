import { isAddress, zeroAddress } from "viem";
import { Address, ConfigData, Hyperparameters, OracleReadType, QuoteType } from "./types";

// return token address defined in config.tokens
export const getTokenAddressFromConfig = (token: string, config: ConfigData) => {
  if (!Object.keys(config.tokens).includes(token.toLowerCase())) throw new Error(`Token ${token} not found in config`);
  const tokenAddress = config.tokens[token.toLowerCase() as keyof typeof config.tokens];
  if (!isAddressValid(tokenAddress)) throw new Error(`Invalid ${token} address: ${tokenAddress}`);
  return tokenAddress;
};

export const getWalletAddressFromConfig = (wallet: string, config: ConfigData) => {
  if (!Object.keys(config.wallets).includes(wallet.toLowerCase()))
    throw new Error(`Wallet ${wallet} not found in config`);
  const walletAddress = config.wallets[wallet.toLowerCase() as keyof typeof config.wallets];
  if (!isAddressValid(walletAddress)) throw new Error(`Invalid ${wallet} address: ${walletAddress}`);
  return walletAddress;
};

export const checkAddressValid = (address: Address, label: string) => {
  if (!isAddressValid(address)) throw new Error(`Invalid ${label} address: ${address}`);
  return address;
};

export const isAddressValid = (address: string) => {
  return isAddress(address) && zeroAddress !== address;
};

export const parseToConfigData = (config: any): ConfigData => {
  return {
    ...config,
    parallelizer: Object.fromEntries(
      Object.entries(config.parallelizer).map(([key, value]: [string, any]) => [
        key,
        {
          ...value,
          collaterals: value.collaterals.map(({ xMintFee, yMintFee, xBurnFee, yBurnFee, oracle, token }: any) => {
            checkAddressValid(token, `Invalid ${token} collateral address`);
            if (!(oracle.oracleType in OracleReadType)) {
              throw new Error(`${token} Invalid oracle type: ${oracle.oracleType}`);
            }
            if (!(oracle.targetType in OracleReadType)) {
              throw new Error(`${token} Invalid target type: ${oracle.targetType}`);
            }
            if (oracle.quoteType && !(oracle.quoteType in QuoteType)) {
              throw new Error(`${token} Invalid quote type: ${oracle.quoteType}`);
            }
            if (xMintFee.length !== yMintFee.length) {
              throw new Error(`Mint fee array must have the same length`);
            }
            if (xBurnFee.length !== yBurnFee.length) {
              throw new Error(`Burn fee array must have the same length`);
            }

            let hyperparameters: Hyperparameters | undefined;
            if (oracle.hyperparameters) {
              hyperparameters = {
                userDeviation: BigInt(oracle.hyperparameters.userDeviation),
                burnRatioDeviation: BigInt(oracle.hyperparameters.burnRatioDeviation),
              };
            }

            return {
              token,
              oracle: {
                ...oracle,
                quoteType: oracle.quoteType ? QuoteType[oracle.quoteType as keyof typeof QuoteType] : undefined,
                oracleType: OracleReadType[oracle.oracleType as keyof typeof OracleReadType],
                targetType: OracleReadType[oracle.targetType as keyof typeof OracleReadType],
                stalePeriods: oracle.stalePeriods ? oracle.stalePeriods.map((x: string | number) => BigInt(x)) : [],
                hyperparameters: hyperparameters,
              },
              xMintFee: xMintFee.map((x: string | number) => BigInt(x)),
              yMintFee: yMintFee.map((x: string | number) => BigInt(x)),
              xBurnFee: xBurnFee.map((x: string | number) => BigInt(x)),
              yBurnFee: yBurnFee.map((x: string | number) => BigInt(x)),
            };
          }),
          redemptionSetup: {
            xRedeemFee: value.redemptionSetup.xRedeemFee.map((x: string | number) => BigInt(x)),
            yRedeemFee: value.redemptionSetup.yRedeemFee.map((x: string | number) => BigInt(x)),
          },
        },
      ]),
    ),
  };
};
