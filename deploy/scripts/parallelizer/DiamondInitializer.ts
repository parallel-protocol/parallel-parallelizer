import assert from "assert";

import { type DeployFunction } from "hardhat-deploy/types";

const contractName = "DiamondInitializer";

const deploy: DeployFunction = async (hre) => {
  const { getNamedAccounts, deployments } = hre;

  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  assert(deployer, "Missing named deployer account");

  console.log(`Network: ${hre.network.name}`);
  console.log(`Deployer: ${deployer}`);

  console.log(`Deploying ${contractName}...`);

  const initializer = await deploy(contractName, {
    from: deployer,
    log: true,
  });

  console.log(`Deployed contract: ${contractName}, network: ${hre.network.name}, address: ${initializer.address}`);
};

deploy.tags = [contractName];

export default deploy;
