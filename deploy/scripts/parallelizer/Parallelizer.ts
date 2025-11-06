import assert from "assert";
import { deployScript, artifacts } from "@rocketh";
import { Abi, encodeAbiParameters, encodeFunctionData, Hex, parseAbiParameters, toFunctionSelector } from "viem";

import {
  ChainlinkFeedsConfig,
  CollateralConfig,
  CollateralSetupParams,
  MorphoOracleConfig,
  OracleReadType,
  RedemptionSetup,
} from "../../utils/types";

import { readFileSync } from "fs";
import { checkAddressValid, getTokenAddressFromConfig, parseToConfigData } from "../../utils";
import { Deployment } from "rocketh";

const contractName = "Parallelizer";

const token = "USDp";

enum FacetCutAction {
  Add,
  Replace,
  Remove,
}

export default deployScript(
  async ({ namedAccounts, network, deploy, get }) => {
    const { deployer } = namedAccounts;
    const chainName = network.chain.name;
    assert(deployer, "Missing named deployer account");
    console.log(`Network: ${chainName} \n Deployer: ${deployer} \n Deploying ${contractName}`);

    const config = parseToConfigData(
      JSON.parse(readFileSync(`./deploy/config/${chainName.toLowerCase()}/config.json`).toString()),
    );
    const tokenPAddress = getTokenAddressFromConfig(token, config);
    if (!tokenPAddress) throw new Error(`Token ${token} address not found in config`);

    const accessManager = checkAddressValid(config.accessManager, "access manager");

    const parallelizerConfig = config.parallelizer[token.toLowerCase() as keyof typeof config.parallelizer];
    if (!parallelizerConfig) throw new Error(`Parallelizer config for ${token} not found in config`);

    let collateralArgs = [];
    const collaterals = parallelizerConfig.collaterals;

    for (const collateral of collaterals) {
      if (!collateral) throw new Error(`Collateral ${collateral} has no oracle config`);
      const collateralSetup = setUpCollateral(collateral);
      collateralArgs.push(collateralSetup);
    }

    const redemptionSetup = setUpRedemption(parallelizerConfig.redemptionSetup);

    const initializer = get("DiamondInitializer");
    const callData = encodeFunctionData({
      abi: initializer.abi,
      functionName: "initialize",
      args: [accessManager, tokenPAddress, collateralArgs, redemptionSetup],
    });
    const facets = await getFacetsWithSelectors(get);

    const cuts = facets.map((facet) => facet.cut);
    const parallelizer = await deploy(`${contractName}_${token}`, {
      artifact: artifacts.DiamondProxy,
      account: deployer,
      args: [cuts, initializer.address, callData],
    });

    console.log(`Deployed contract: ${contractName}_${token}, network: ${chainName}, address: ${parallelizer.address}`);
  },
  {
    tags: [contractName],
    dependencies: ["DiamondInitializer", "Facets"],
  },
);

const getFacetsWithSelectors = async (get: <TAbi extends Abi>(name: string) => Deployment<TAbi>) => {
  const facetsList = [
    "DiamondCut",
    "DiamondLoupe",
    "SettersGovernor",
    "SettersGuardian",
    "Getters",
    "Swapper",
    "Redeemer",
    "RewardHandler",
  ];
  const facets = [];
  for (const facet of facetsList) {
    const facetContract = get(facet);
    const cut = {
      facetAddress: facetContract.address,
      action: Number(FacetCutAction.Add),
      functionSelectors: getSelectors(facetContract),
    };
    facets.push({
      facetContract,
      cut,
    });
  }
  return facets;
};

function sigsFromABI(abi: Abi): Hex[] {
  return abi
    .filter((fragment: any) => fragment.type === "function")
    .map((fragment: any) => toFunctionSelector(fragment));
}

const getSelectors = (contract: Deployment<Abi>) => {
  return sigsFromABI(contract.abi);
};

const setUpCollateral = (collateral: CollateralConfig): CollateralSetupParams => {
  const { token, oracle, xMintFee, yMintFee, xBurnFee, yBurnFee } = collateral;

  let readData: Hex = "0x";
  if (oracle.oracleType === OracleReadType.CHAINLINK_FEEDS) {
    const { circuitChainlink, stalePeriods, circuitChainIsMultiplied, chainlinkDecimals, quoteType } =
      oracle as ChainlinkFeedsConfig;
    if (
      circuitChainlink.length != stalePeriods.length ||
      circuitChainlink.length != circuitChainIsMultiplied.length ||
      circuitChainlink.length != chainlinkDecimals.length
    ) {
      throw new Error(`Chainlink feeds config must have the same length`);
    }

    readData = encodeAbiParameters(parseAbiParameters("address[], uint32[], uint8[], uint8[], uint8"), [
      circuitChainlink,
      stalePeriods,
      circuitChainIsMultiplied,
      chainlinkDecimals,
      quoteType,
    ]);
  }
  if (oracle.oracleType === OracleReadType.MORPHO_ORACLE) {
    const { oracleAddress, normalizationFactor } = oracle as MorphoOracleConfig;
    if (!oracleAddress || !normalizationFactor) {
      throw new Error(`Morpho oracle config must have an oracle address and normalization factor`);
    }
    readData = encodeAbiParameters(parseAbiParameters("address, uint256"), [oracleAddress, normalizationFactor]);
  }

  let targetData: Hex =
    oracle.targetType === OracleReadType.MAX ? encodeAbiParameters(parseAbiParameters("uint256"), [0n]) : "0x";

  let hyperparametersData: Hex = "0x";
  if (oracle.hyperparameters) {
    hyperparametersData = encodeAbiParameters(parseAbiParameters("uint128, uint128"), [
      oracle.hyperparameters.userDeviation,
      oracle.hyperparameters.burnRatioDeviation,
    ]);
  }

  const oracleConfig = encodeAbiParameters(parseAbiParameters("uint8, uint8, bytes, bytes, bytes"), [
    oracle.oracleType,
    oracle.targetType,
    readData,
    targetData,
    hyperparametersData,
  ]);

  return {
    token,
    targetMax: oracle.targetType === OracleReadType.MAX,
    oracleConfig,
    xMintFee,
    yMintFee,
    xBurnFee,
    yBurnFee,
  };
};

const setUpRedemption = (redemption?: RedemptionSetup): RedemptionSetup => {
  if (!redemption) throw new Error(`Redemption setup not found in config`);
  if (redemption.xRedeemFee.length !== redemption.yRedeemFee.length) {
    throw new Error(`Redemption setup must have the same length`);
  }
  return redemption;
};
