import assert from "assert";
import { deployScript, artifacts } from "@rocketh";

const contractName = "SettersGovernor";

export default deployScript(
  async ({ namedAccounts, network, deploy }) => {
    const { deployer } = namedAccounts;
    const chainName = network.chain.name;
    assert(deployer, "Missing named deployer account");
    console.log(`Network: ${chainName} \n Deployer: ${deployer} \n Deploying facet: ${contractName}`);

    const settersGovernor = await deploy(contractName, {
      account: deployer,
      artifact: artifacts.SettersGovernor,
      args: [],
    });

    console.log(`Deployed facet: ${contractName}, network: ${chainName}, address: ${settersGovernor.address}`);
  },
  {
    tags: ["Facets", contractName],
  },
);
