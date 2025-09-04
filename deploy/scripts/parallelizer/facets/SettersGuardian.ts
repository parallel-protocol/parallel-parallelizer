import assert from "assert";
import { deployScript, artifacts } from "@rocketh";

const contractName = "SettersGuardian";

export default deployScript(
  async ({ namedAccounts, network, deploy }) => {
    const { deployer } = namedAccounts;
    const chainName = network.chain.name;
    assert(deployer, "Missing named deployer account");
    console.log(`Network: ${chainName} \n Deployer: ${deployer} \n Deploying facet: ${contractName}`);

    const settersGuardian = await deploy(contractName, {
      account: deployer,
      artifact: artifacts.SettersGuardian,
      args: [],
    });

    console.log(`Deployed facet: ${contractName}, network: ${chainName}, address: ${settersGuardian.address}`);
  },
  {
    tags: ["Facets", contractName],
  },
);
