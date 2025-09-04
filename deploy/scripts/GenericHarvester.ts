import assert from "assert";
import { deployScript, artifacts } from "@rocketh";

import { checkAddressValid, parseToConfigData } from "../utils";
import { readFileSync } from "fs";

const contractName = "GenericHarvester";

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

    const genericHarvesterConfig = config.genericHarvester[token.toLowerCase() as keyof typeof config.genericHarvester];
    const swapRouter = checkAddressValid(genericHarvesterConfig.swapRouter, "Invalid swapRouter address");
    const tokenTransferAddress = checkAddressValid(
      genericHarvesterConfig.tokenTransferAddress,
      "Invalid tokenTransferAddress address",
    );

    const flashloan = checkAddressValid(genericHarvesterConfig.flashloan, "Invalid flashloan address");
    const parallelizer = get(`Parallelizer_${token}`);
    if (!parallelizer) {
      throw new Error(`Parallelizer_${token} not found`);
    }

    const genericHarvester = await deploy(`${contractName}_${token}`, {
      account: deployer,
      artifact: artifacts.GenericHarvester,
      args: [tokenTransferAddress, swapRouter, tokenP, parallelizer.address, accessManager, flashloan],
    });

    console.log(`Deployed ${contractName}_${token}, network: ${chainName}, address: ${genericHarvester.address}`);
  },
  {
    tags: [contractName],
  },
);
