import assert from "assert";
import { deployScript, artifacts } from "@rocketh";
import {
  Abi,
  Address,
  encodeAbiParameters,
  encodeFunctionData,
  Hex,
  parseAbiParameters,
  PublicClient,
  toFunctionSelector,
  zeroAddress,
} from "viem";

import {
  ChainlinkFeedsConfig,
  CollateralConfig,
  CollateralSetupParams,
  MorphoOracleConfig,
  OracleReadType,
  RedemptionSetup,
} from "../../utils/types";

import { readFileSync } from "fs";
import { checkAddressValid, getTokenAddressFromConfig, parseToConfigData } from "../../utils";
import { Artifact, Deployment } from "rocketh";
import { AccessManagerAbi } from "../../abis/AccessManager";
import { get } from "http";
import { FacetCut } from "@rocketh/diamond/types";

const contractName = "UpdateParallelizer";

const token = "USDp";

enum FacetCutAction {
  Add,
  Replace,
  Remove,
}

type Facet = {
  facetAddress: `0x${string}`;
  functionSelectors: readonly `0x${string}`[];
};

const diamondCutSelector = "0x1f931c1c";

type DiamondCutABI = typeof artifacts.DiamondCut.abi;

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
  async ({ namedAccounts, network, get, viem, deploy, execute }) => {
    const { deployer } = namedAccounts;
    const chainName = network.chain.name;
    assert(deployer, "Missing named deployer account");
    console.log(`Network: ${chainName} \n Caller: ${deployer} \n Updating ${contractName}`);

    const config = parseToConfigData(
      JSON.parse(readFileSync(`./deploy/config/${chainName.toLowerCase()}/config.json`).toString()),
    );

    const accessManager = checkAddressValid(config.accessManager, "access manager");

    const parallelizer = get(`Parallelizer_${token}`);

    const [canCall] = (await viem.publicClient.readContract({
      abi: AccessManagerAbi,
      address: accessManager,
      functionName: "canCall",
      args: [deployer, parallelizer.address, diamondCutSelector],
    })) as unknown as [boolean, bigint];

    if (!canCall) throw new Error("Caller is not allowed to call diamondCut");

    const { oldSelectors, oldSelectorsFacetAddress } = await getOldFacetSelectors(
      parallelizer.address,
      viem.publicClient,
    );

    const newSelectors: string[] = [];
    const facetSnapshot: Facet[] = [];
    const newFacetDeployed: string[] = [];
    for (const facet of FACETS_LIST) {
      const implementation = await deploy(facet, {
        account: deployer,
        artifact: artifacts[facet as keyof typeof artifacts] as Artifact<Abi>,
        args: [],
      });

      let facetAddress: `0x${string}`;
      if (implementation.newlyDeployed) {
        facetAddress = implementation.address;
        const newFacet = {
          facetAddress,
          functionSelectors: sigsFromABI(implementation.abi),
        };
        facetSnapshot.push(newFacet);
        newSelectors.push(...newFacet.functionSelectors);
        newFacetDeployed.push(facet);
      } else {
        const oldImpl = get(facet);
        facetAddress = oldImpl.address;
        const newFacet = {
          facetAddress,
          functionSelectors: sigsFromABI(oldImpl.abi),
        };
        facetSnapshot.push(newFacet);
        newSelectors.push(...newFacet.functionSelectors);
      }
    }

    let changesDetected = false;
    const facetCuts: FacetCut[] = [];

    for (const newFacet of facetSnapshot) {
      const selectorsToAdd: `0x${string}`[] = [];
      const selectorsToReplace: `0x${string}`[] = [];

      for (const selector of newFacet.functionSelectors) {
        if (oldSelectors.indexOf(selector) >= 0) {
          if (oldSelectorsFacetAddress[selector].toLowerCase() !== newFacet.facetAddress.toLowerCase()) {
            selectorsToReplace.push(selector);
          }
        } else {
          selectorsToAdd.push(selector);
        }
      }

      if (selectorsToReplace.length > 0) {
        changesDetected = true;
        facetCuts.push({
          facetAddress: newFacet.facetAddress,
          functionSelectors: selectorsToReplace,
          action: FacetCutAction.Replace,
        });
      }

      if (selectorsToAdd.length > 0) {
        changesDetected = true;
        facetCuts.push({
          facetAddress: newFacet.facetAddress,
          functionSelectors: selectorsToAdd,
          action: FacetCutAction.Add,
        });
      }
    }

    if (!changesDetected) {
      console.log("No changes detected");
      return;
    }

    await viem.walletClient.writeContract({
      chain: network.chain,
      account: deployer,
      address: parallelizer.address,
      abi: artifacts.DiamondCut.abi as Abi,
      functionName: "diamondCut",
      args: [facetCuts, zeroAddress, "0x"],
    });

    console.log(
      `Updated contract: ${contractName}_${token}, network: ${chainName}, facets deployed: ${newFacetDeployed.join(", ")}`,
    );
  },
  {
    tags: [contractName],
  },
);

async function getOldFacetSelectors(
  address: Address,
  publicClient: PublicClient,
): Promise<{ oldSelectors: `0x${string}`[]; oldSelectorsFacetAddress: { [selector: `0x${string}`]: `0x${string}` } }> {
  let oldFacets: readonly Facet[] = [];
  oldFacets = await publicClient.readContract({
    abi: artifacts.DiamondLoupe.abi,
    address,
    functionName: "facets",
  });

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
  return abi
    .filter((fragment: any) => fragment.type === "function")
    .map((fragment: any) => toFunctionSelector(fragment));
}

// const getFacetsWithSelectors = async (get: <TAbi extends Abi>(name: string) => Deployment<TAbi>) => {
//   const facetsList = [
//     "DiamondCut",
//     "DiamondLoupe",
//     "SettersGovernor",
//     "SettersGuardian",
//     "Getters",
//     "Swapper",
//     "Redeemer",
//     "RewardHandler",
//   ];
//   const facets = [];
//   for (const facet of facetsList) {
//     const facetContract = get(facet);
//     const cut = {
//       facetAddress: facetContract.address,
//       action: Number(FacetCutAction.Add),
//       functionSelectors: getSelectors(facetContract),
//     };
//     facets.push({
//       facetContract,
//       cut,
//     });
//   }
//   return facets;
// };

// function sigsFromABI(abi: Abi): Hex[] {
//   return abi
//     .filter((fragment: any) => fragment.type === "function")
//     .map((fragment: any) => toFunctionSelector(fragment));
// }
