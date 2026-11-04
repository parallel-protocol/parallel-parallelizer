import { checkAddressValid } from "./index";

export type Address = `0x${string}`;

export enum OracleReadType {
  CHAINLINK_FEEDS,
  EXTERNAL,
  NO_ORACLE,
  STABLE,
  WSTETH,
  CBETH,
  RETH,
  SFRXETH,
  MAX,
  MORPHO_ORACLE,
}

export enum QuoteType {
  UNIT,
  TARGET,
}

export type CollateralSetupParams = {
  token: Address;
  targetMax: boolean;
  oracleConfig: string;
  xMintFee: bigint[];
  yMintFee: bigint[];
  xBurnFee: bigint[];
  yBurnFee: bigint[];
};

export type ChainlinkFeedsConfig = OracleBaseConfig & {
  circuitChainlink: Address[];
  stalePeriods: number[];
  circuitChainIsMultiplied: number[];
  chainlinkDecimals: number[];
  quoteType: QuoteType;
};

export type MorphoOracleConfig = OracleBaseConfig & {
  oracleAddress: Address;
  normalizationFactor: bigint;
};

export type Hyperparameters = {
  userDeviation: bigint;
  burnRatioDeviation: bigint;
};

export type OracleBaseConfig = {
  oracleType: OracleReadType;
  targetType: OracleReadType;
  hyperparameters?: Hyperparameters;
  targetData?: string;
};

export type RedemptionSetup = {
  xRedeemFee: bigint[];
  yRedeemFee: bigint[];
};

export type OracleConfig = ChainlinkFeedsConfig | MorphoOracleConfig;

export type CollateralConfig = {
  token: Address;
  oracle: OracleConfig;
  xMintFee: bigint[];
  yMintFee: bigint[];
  xBurnFee: bigint[];
  yBurnFee: bigint[];
};

export type ParallelizerConfig = {
  collaterals: CollateralConfig[];
  redemptionSetup: RedemptionSetup;
};

export type SavingsConfig = {
  name: string;
  symbol: string;
};

export type GenericRebalancerConfig = {
  swapRouter: Address;
  tokenTransferAddress: Address;
  flashloan: Address;
};

export type ConfigData = {
  accessManager: Address;
  wallets: {
    dao: Address;
  };
  tokens: {
    [tokenP: string]: Address;
  };
  parallelizer: {
    [tokenP: string]: ParallelizerConfig;
  };
  savings: {
    [tokenP: string]: SavingsConfig;
  };
  genericRebalancer: {
    [tokenP: string]: GenericRebalancerConfig;
  };
};
