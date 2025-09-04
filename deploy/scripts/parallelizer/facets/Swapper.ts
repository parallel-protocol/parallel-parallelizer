import assert from "assert";
import { deployScript, artifacts } from "@rocketh";

const contractName = "Swapper";

export default deployScript(
  async ({ namedAccounts, network, deploy }) => {
    const { deployer } = namedAccounts;
    const chainName = network.chain.name;
    assert(deployer, "Missing named deployer account");
    console.log(`Network: ${chainName} \n Deployer: ${deployer} \n Deploying facet: ${contractName}`);

    const swapper = await deploy(contractName, {
      account: deployer,
      artifact: artifacts.Swapper,
      args: [],
    });

    console.log(`Deployed facet: ${contractName}, network: ${chainName}, address: ${swapper.address}`);
  },
  {
    tags: ["Facets", contractName],
  },
);
