import assert from "assert";
import { ethers, utils } from "ethers";

import { type DeployFunction } from "hardhat-deploy/types";
import { checkAddressValid, parseToConfigData } from "../utils";
import { readFileSync } from "fs";

const contractName = "GenericHarvester";

const token = "USDp";

const deploy: DeployFunction = async (hre) => {
  const { getNamedAccounts, deployments, network } = hre;

  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  assert(deployer, "Missing named deployer account");

  const config = parseToConfigData(JSON.parse(readFileSync(`./deploy/config/${network.name}/config.json`).toString()));

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
  const parallelizer = await hre.deployments.get(`Parallelizer_${token}`);
  if (!parallelizer) {
    throw new Error(`Parallelizer_${token} not found`);
  }

  const genericHarvester = await deploy(`${contractName}_${token}`, {
    contract: contractName,
    from: deployer,
    args: [tokenTransferAddress, swapRouter, tokenP, parallelizer.address, accessManager, flashloan],
    log: true,
    skipIfAlreadyDeployed: true,
    gasLimit: 5000000,
  });

  console.log(`Deployed ${contractName}_${token}, network: ${network.name}, address: ${genericHarvester.address}`);
};

deploy.tags = [contractName];

export default deploy;
