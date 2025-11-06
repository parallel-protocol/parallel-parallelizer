import assert from "assert";
import { deployScript, artifacts } from "@rocketh";

const contractName = "DiamondInitializer";

export default deployScript(
  async ({ namedAccounts, network, deploy }) => {
    const { deployer } = namedAccounts;
    const chainName = network.chain.name;
    assert(deployer, "Missing named deployer account");
    console.log(`Network: ${chainName} \n Deployer: ${deployer} \n Deploying ${contractName}`);

    const initializer = await deploy(contractName, {
      account: deployer,
      artifact: artifacts.DiamondInitializer,
      args: [],
    });

    console.log(`Deployed contract: ${contractName}, network: ${chainName}, address: ${initializer.address}`);
  },
  {
    tags: [contractName],
  },
);
