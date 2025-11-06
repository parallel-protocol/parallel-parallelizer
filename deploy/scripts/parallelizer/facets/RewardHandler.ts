import assert from "assert";
import { deployScript, artifacts } from "@rocketh";

const contractName = "RewardHandler";

export default deployScript(
  async ({ namedAccounts, network, deploy }) => {
    const { deployer } = namedAccounts;
    const chainName = network.chain.name;
    assert(deployer, "Missing named deployer account");
    console.log(`Network: ${chainName} \n Deployer: ${deployer} \n Deploying facet: ${contractName}`);

    const rewardHandler = await deploy(contractName, {
      account: deployer,
      artifact: artifacts.RewardHandler,
      args: [],
    });

    console.log(`Deployed facet: ${contractName}, network: ${chainName}, address: ${rewardHandler.address}`);
  },
  {
    tags: ["Facets", contractName],
  },
);
