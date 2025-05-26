import assert from "assert";

import { type DeployFunction } from "hardhat-deploy/types";

const contractName = "DiamondEtherscan";

const deploy: DeployFunction = async (hre) => {
  const { getNamedAccounts, deployments } = hre;

  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  assert(deployer, "Missing named deployer account");

  console.log(`Network: ${hre.network.name}`);
  console.log(`Deployer: ${deployer}`);

  console.log(`Deploying facet ${contractName}...`);

  const diamondEtherscan = await deploy(contractName, {
    from: deployer,
    skipIfAlreadyDeployed: true,
    log: true,
  });

  console.log(`Deployed facet: ${contractName}, network: ${hre.network.name}, address: ${diamondEtherscan.address}`);
};

deploy.tags = ["Facets", contractName];

export default deploy;
