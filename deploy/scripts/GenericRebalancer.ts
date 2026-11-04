import assert from "assert";
import { deployScript, artifacts } from "@rocketh";

import { checkAddressValid, parseToConfigData } from "../utils";
import { readFileSync } from "fs";

const contractName = "GenericRebalancer";

const token = "USDp";

export default deployScript(
  async ({ namedAccounts, network, deploy, get }) => {
    const { deployer } = namedAccounts;
    const chainName = network.chain.name;
    assert(deployer, "Missing named deployer account");
    console.log(`Network: ${chainName} \n Deployer: ${deployer} \n Deploying facet: ${contractName}`);

    const config = parseToConfigData(
      JSON.parse(readFileSync(`./deploy/config/${network.name}/config.json`).toString()),
    );

    console.log(`Network: ${network.name}`);
    console.log(`Deployer: ${deployer}`);

    const accessManager = checkAddressValid(config.accessManager, "Invalid AccessManager address");
    const tokenP = checkAddressValid(
      config.tokens[token.toLowerCase() as keyof typeof config.tokens],
      "Invalid tokenP address",
    );

    const genericRebalancerConfig = config.genericRebalancer[token.toLowerCase() as keyof typeof config.genericRebalancer];
    const swapRouter = checkAddressValid(genericRebalancerConfig.swapRouter, "Invalid swapRouter address");
    const tokenTransferAddress = checkAddressValid(
      genericRebalancerConfig.tokenTransferAddress,
      "Invalid tokenTransferAddress address",
    );

    const flashloan = checkAddressValid(genericRebalancerConfig.flashloan, "Invalid flashloan address");
    const parallelizer = get(`Parallelizer_${token}`);
    if (!parallelizer) {
      throw new Error(`Parallelizer_${token} not found`);
    }

    const genericRebalancer = await deploy(`${contractName}_${token}`, {
      account: deployer,
      artifact: artifacts.GenericRebalancer,
      args: [tokenTransferAddress, swapRouter, tokenP, parallelizer.address, accessManager, flashloan],
    });

    console.log(`Deployed ${contractName}_${token}, network: ${chainName}, address: ${genericRebalancer.address}`);
  },
  {
    tags: [contractName],
  },
);
