import assert from "assert";
import { deployScript, artifacts } from "@rocketh";
import { encodeFunctionData } from "viem";

/// Deploys ONLY the new Savings implementation (no proxy upgrade), then prints the `upgradeToAndCall`
/// transaction for the multisig. The proxy is owned by governance, so the deployer cannot upgrade it.
const token = "USDp";

export default deployScript(
  async ({ namedAccounts, network, deploy, get }) => {
    const { deployer } = namedAccounts;
    const chainName = network.chain.name;
    assert(deployer, "Missing named deployer account");
    console.log(`Network: ${chainName}\nDeployer: ${deployer}\nDeploying Savings implementation (no wiring)`);

    // BaseSavings' constructor calls _disableInitializers(), so the implementation is safe to leave
    // uninitialized. Re-runs only redeploy when the bytecode changed.
    const implementation = await deploy(`Savings_${token}_Implementation`, {
      account: deployer,
      artifact: artifacts.SavingsNameable,
      args: [],
    });
    console.log(`New SavingsNameable implementation: ${implementation.address}`);

    const proxy = get(`Savings_${token}`);

    const initializeStoredAssetsData = encodeFunctionData({
      abi: artifacts.SavingsNameable.abi,
      functionName: "initializeStoredAssets",
      args: [],
    });

    const upgradeToAndCallData = encodeFunctionData({
      abi: artifacts.SavingsNameable.abi,
      functionName: "upgradeToAndCall",
      args: [implementation.address, initializeStoredAssetsData],
    });

    console.log("\n=== Multisig action — Savings proxy upgrade ===");
    console.log(`to:    ${proxy.address}`);
    console.log(`value: 0`);
    console.log(`data:  ${upgradeToAndCallData}`);
    console.log(`decoded: upgradeToAndCall(${implementation.address}, initializeStoredAssets())`);
    console.log(
      "\nReminder: refresh accrual (setRate) shortly before the upgrade so the initializeStoredAssets staleness guard passes.",
    );
  },
  {
    tags: ["UpgradeSavings", "SavingsImplementation"],
  },
);
