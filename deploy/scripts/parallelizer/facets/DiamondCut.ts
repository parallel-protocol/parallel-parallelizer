import assert from "assert";
import { deployScript, artifacts } from "@rocketh";

const contractName = "DiamondCut";

export default deployScript(
  async ({ namedAccounts, network, deploy }) => {
    const { deployer } = namedAccounts;
    const chainName = network.chain.name;
    assert(deployer, "Missing named deployer account");
    console.log(`Network: ${chainName} \n Deployer: ${deployer} \n Deploying facet: ${contractName}`);

    const diamondCut = await deploy(contractName, {
      account: deployer,
      artifact: artifacts.DiamondCut,
      args: [],
    });

    console.log(`Deployed facet: ${contractName}, network: ${chainName}, address: ${diamondCut.address}`);
  },
  {
    tags: ["Facets", contractName],
  },
);
