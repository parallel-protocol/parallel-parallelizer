import assert from "assert";
import { deployScript, artifacts } from "@rocketh";
import { Abi, Address, Hex, PublicClient, encodeFunctionData, toFunctionSelector, zeroAddress } from "viem";
import { Artifact } from "rocketh";

/// Deploys the parallelizer facets (only changed ones are actually redeployed) and computes the
/// `diamondCut` by diffing the on-chain selectors against the freshly-compiled facets. It PRINTS the
/// facetCuts and the encoded `diamondCut` transaction instead of executing it, because only the
/// multisig can call `diamondCut`. Mirrors the diff logic of `UpdateParallelizer.ts` without executing.
const token = "USDp";

enum FacetCutAction {
  Add,
  Replace,
  Remove,
}

type Facet = { facetAddress: `0x${string}`; functionSelectors: readonly `0x${string}`[] };
type FacetCut = { facetAddress: `0x${string}`; functionSelectors: `0x${string}`[]; action: FacetCutAction };

const FACETS_LIST = [
  "DiamondCut",
  "DiamondLoupe",
  "SettersGovernor",
  "SettersGuardian",
  "Getters",
  "Swapper",
  "Redeemer",
  "RewardHandler",
  "Surplus",
];

export default deployScript(
  async ({ namedAccounts, network, get, viem, deploy }) => {
    const { deployer } = namedAccounts;
    const chainName = network.chain.name;
    assert(deployer, "Missing named deployer account");
    console.log(`Network: ${chainName}\nDeployer: ${deployer}\nPreparing parallelizer diamondCut (deploy facets only)`);

    const parallelizer = get(`Parallelizer_${token}`);

    const { oldSelectors, oldSelectorsFacetAddress } = await getOldFacetSelectors(
      parallelizer.address,
      viem.publicClient,
    );

    const newSelectors: string[] = [];
    const facetSnapshot: Facet[] = [];
    const redeployed: string[] = [];
    for (const facet of FACETS_LIST) {
      const implementation = await deploy(facet, {
        account: deployer,
        artifact: artifacts[facet as keyof typeof artifacts] as Artifact<Abi>,
        args: [],
      });
      const selectors = sigsFromABI(implementation.abi);
      facetSnapshot.push({ facetAddress: implementation.address, functionSelectors: selectors });
      newSelectors.push(...selectors);
      if (implementation.newlyDeployed) redeployed.push(`${facet} -> ${implementation.address}`);
    }

    const facetCuts: FacetCut[] = [];
    for (const facet of facetSnapshot) {
      const toAdd: `0x${string}`[] = [];
      const toReplace: `0x${string}`[] = [];
      for (const selector of facet.functionSelectors) {
        if (oldSelectors.indexOf(selector) >= 0) {
          if (oldSelectorsFacetAddress[selector].toLowerCase() !== facet.facetAddress.toLowerCase()) {
            toReplace.push(selector);
          }
        } else {
          toAdd.push(selector);
        }
      }
      if (toReplace.length > 0) {
        facetCuts.push({ facetAddress: facet.facetAddress, functionSelectors: toReplace, action: FacetCutAction.Replace });
      }
      if (toAdd.length > 0) {
        facetCuts.push({ facetAddress: facet.facetAddress, functionSelectors: toAdd, action: FacetCutAction.Add });
      }
    }

    const toDelete: `0x${string}`[] = [];
    for (const selector of oldSelectors) {
      if (newSelectors.indexOf(selector) === -1) toDelete.push(selector);
    }
    if (toDelete.length > 0) {
      facetCuts.unshift({ facetAddress: zeroAddress, functionSelectors: toDelete, action: FacetCutAction.Remove });
    }

    if (facetCuts.length === 0) {
      console.log("No changes detected — diamond already up to date.");
      return;
    }

    const diamondCutData = encodeFunctionData({
      abi: artifacts.DiamondCut.abi as Abi,
      functionName: "diamondCut",
      args: [facetCuts, zeroAddress, "0x"],
    });

    console.log(`\nFacets redeployed: ${redeployed.length ? redeployed.join(", ") : "none"}`);
    console.log("\n=== FacetCuts (0=Add, 1=Replace, 2=Remove) ===");
    console.log(JSON.stringify(facetCuts, null, 2));
    console.log("\n=== Multisig action — parallelizer diamondCut ===");
    console.log(`to:    ${parallelizer.address}`);
    console.log(`value: 0`);
    console.log(`data:  ${diamondCutData}`);
  },
  {
    tags: ["PrepareParallelizerUpgrade"],
  },
);

async function getOldFacetSelectors(
  address: Address,
  publicClient: PublicClient,
): Promise<{ oldSelectors: `0x${string}`[]; oldSelectorsFacetAddress: { [selector: `0x${string}`]: `0x${string}` } }> {
  const oldFacets = (await publicClient.readContract({
    abi: artifacts.DiamondLoupe.abi,
    address,
    functionName: "facets",
  })) as readonly Facet[];

  const oldSelectors: `0x${string}`[] = [];
  const oldSelectorsFacetAddress: { [selector: `0x${string}`]: `0x${string}` } = {};
  for (const facet of oldFacets) {
    for (const selector of facet.functionSelectors) {
      oldSelectors.push(selector);
      oldSelectorsFacetAddress[selector] = facet.facetAddress;
    }
  }
  return { oldSelectors, oldSelectorsFacetAddress };
}

function sigsFromABI(abi: Abi): Hex[] {
  return abi.filter((fragment: any) => fragment.type === "function").map((fragment: any) => toFunctionSelector(fragment));
}
