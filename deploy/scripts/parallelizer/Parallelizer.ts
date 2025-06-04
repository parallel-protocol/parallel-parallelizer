import assert from "assert";
import { defaultAbiCoder as abiCoder, FunctionFragment, Interface } from "@ethersproject/abi";
import { BigNumber } from "ethers";

import { DeploymentsExtension, type DeployFunction, Deployment } from "hardhat-deploy/types";

import {
  ChainlinkFeedsConfig,
  CollateralConfig,
  CollateralSetupParams,
  MorphoOracleConfig,
  OracleReadType,
  RedemptionSetup,
} from "../../utils/types";

import { readFileSync } from "fs-extra";
import { checkAddressValid, getTokenAddressFromConfig, parseToConfigData } from "../../utils";

const contractName = "Parallelizer";

const token = "USDp";

enum FacetCutAction {
  Add,
  Replace,
  Remove,
}

const deploy: DeployFunction = async (hre) => {
  const { getNamedAccounts, deployments } = hre;

  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  assert(deployer, "Missing named deployer account");

  console.log(`Network: ${hre.network.name}`);
  console.log(`Deployer: ${deployer}`);

  const config = parseToConfigData(
    JSON.parse(readFileSync(`./deploy/config/${hre.network.name}/config.json`).toString()),
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

  const initializer = await deployments.get("DiamondInitializer");
  const callData = new Interface(initializer.abi).encodeFunctionData("initialize", [
    accessManager,
    tokenPAddress,
    collateralArgs,
    redemptionSetup,
  ]);

  const facets = await getFacetsWithSelectors(deployments);
  const cuts = facets.map((facet) => facet.cut);
  const parallelizer = await deploy(`${contractName}_${token}`, {
    contract: "DiamondProxy",
    from: deployer,
    args: [cuts, initializer.address, callData],
    log: true,
    skipIfAlreadyDeployed: true,
  });

  console.log(
    `Deployed contract: ${contractName}_${token}, network: ${hre.network.name}, address: ${parallelizer.address}`,
  );
};

deploy.tags = [contractName];
deploy.dependencies = ["DiamondInitializer", "Facets"];

export default deploy;

const getFacetsWithSelectors = async (deployments: DeploymentsExtension) => {
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
    const facetContract = await deployments.get(facet);
    const cut = {
      facetAddress: facetContract.address,
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(facetContract),
    };
    facets.push({
      facetContract,
      cut,
    });
  }
  return facets;
};

function sigsFromABI(abi: any[]): string[] {
  return abi
    .filter((fragment: any) => fragment.type === "function")
    .map((fragment: any) => Interface.getSighash(FunctionFragment.from(fragment)));
}

const getSelectors = (contract: Deployment) => {
  return sigsFromABI(contract.abi);
};

const setUpCollateral = (collateral: CollateralConfig): CollateralSetupParams => {
  const { token, oracle, xMintFee, yMintFee, xBurnFee, yBurnFee } = collateral;

  let readData;
  if (oracle.oracleType === OracleReadType.CHAINLINK_FEEDS) {
    const { circuitChainlink, stalePeriods, circuitChainIsMultiplied, chainlinkDecimals } =
      oracle as ChainlinkFeedsConfig;
    if (
      circuitChainlink.length != stalePeriods.length ||
      circuitChainlink.length != circuitChainIsMultiplied.length ||
      circuitChainlink.length != chainlinkDecimals.length
    ) {
      throw new Error(`Chainlink feeds config must have the same length`);
    }
    readData = abiCoder.encode(
      ["address[]", "uint32[]", "uint8[]", "uint8[]", "uint8"],
      [circuitChainlink, stalePeriods, circuitChainIsMultiplied, chainlinkDecimals, oracle.quoteType],
    );
  }
  if (oracle.oracleType === OracleReadType.MORPHO_ORACLE) {
    const { oracleAddress, normalizationFactor } = oracle as MorphoOracleConfig;
    if (!oracleAddress || !normalizationFactor) {
      throw new Error(`Morpho oracle config must have an oracle address and normalization factor`);
    }
    readData = abiCoder.encode(["address", "uint256"], [oracleAddress, normalizationFactor]);
  }
  let targetData = "0x";
  let hyperparametersData = "0x";
  if (oracle.hyperparameters) {
    hyperparametersData = abiCoder.encode(
      ["uint128", "uint128"],
      [oracle.hyperparameters.userDeviation, oracle.hyperparameters.burnRatioDeviation],
    );
  }

  const oracleConfig = abiCoder.encode(
    ["uint8", "uint8", "bytes", "bytes", "bytes"],
    [oracle.oracleType, oracle.targetType, readData, targetData, hyperparametersData],
  );

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
