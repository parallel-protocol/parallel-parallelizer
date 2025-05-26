import assert from "assert";
import { ethers, utils } from "ethers";

import { type DeployFunction } from "hardhat-deploy/types";
import { checkAddressValid, parseToConfigData } from "../utils";
import { readFileSync } from "fs";

import { IERC20Abi } from "../abis/IERC20";

const contractName = "Savings";

const token = "USDp";
const initialDivider = "1";

const deploy: DeployFunction = async (hre) => {
  const { getNamedAccounts, deployments, network } = hre;

  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  assert(deployer, "Missing named deployer account");

  const config = parseToConfigData(
    JSON.parse(readFileSync(`./deploy/config/${hre.network.name}/config.json`).toString()),
  );

  console.log(`Network: ${hre.network.name}`);
  console.log(`Deployer: ${deployer}`);

  const accessManager = checkAddressValid(config.accessManager, "Invalid AccessManager address");
  const tokenP = checkAddressValid(
    config.tokens[token.toLowerCase() as keyof typeof config.tokens],
    "Invalid tokenP address",
  );
  const savingsConfig = config.savings[token.toLowerCase() as keyof typeof config.savings];

  // Deploy the implementation contract if it doesn't exist
  await deploy("SavingsNameable", {
    from: deployer,
    log: true,
    skipIfAlreadyDeployed: false,
  });

  const nonce = await network.provider.send("eth_getTransactionCount", [deployer, "latest"]);

  const futureAddress = utils.getContractAddress({
    from: deployer,
    nonce: parseInt(nonce, 16) + 1,
  });

  const signer = await deployments.getSigner(deployer);
  const tokenPContract = new ethers.Contract(tokenP, IERC20Abi, signer);
  const allowance = await tokenPContract.allowance(deployer, futureAddress);
  if (BigInt(allowance) < BigInt(1e18)) {
    console.log("Approving allowance for future address of 1e18");
    const tx = await tokenPContract.approve(futureAddress, utils.parseUnits(initialDivider, 18));
    await tx.wait();
  }

  const savings = await deploy(`${contractName}_${token}`, {
    from: deployer,
    proxy: {
      proxyContract: "UUPS",
      implementationName: "SavingsNameable",
      execute: {
        methodName: "initialize",
        args: [accessManager, tokenP, savingsConfig.name, savingsConfig.symbol, initialDivider],
      },
    },
    log: true,
    skipIfAlreadyDeployed: false,
  });

  console.log(`Deployed ${contractName}_${token}, network: ${hre.network.name}, address: ${savings.address}`);
};

deploy.tags = [contractName];

export default deploy;
