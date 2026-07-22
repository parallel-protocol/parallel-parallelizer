// ------------------------------------------------------------------------------------------------
// Typed Config
// ------------------------------------------------------------------------------------------------
import type { UserConfig } from "rocketh/types";

export const config = {
  networks: {},
  accounts: {
    deployer: {
      default: 0,
    },
  },
  data: {},
} as const satisfies UserConfig;

// ------------------------------------------------------------------------------------------------
// Imports and Re-exports
// ------------------------------------------------------------------------------------------------
// Extensions are functions that accept the Environment as their first argument. Passing them to
// setupDeployScripts makes them available on the environment object with type-safety in the scripts.
import * as deployExtension from "@rocketh/deploy"; // this one provide a deploy function
import * as readExecuteExtension from "@rocketh/read-execute"; // this one provide read,execute functions
import * as deployProxyExtension from "@rocketh/proxy"; // this one provide a deployViaProxy function that let you declaratively deploy proxy based contracts
import * as viemExtension from "@rocketh/viem"; // this one provide a viem handle to clients and contracts
const extensions = {
  ...deployExtension,
  ...readExecuteExtension,
  ...deployProxyExtension,
  ...viemExtension,
};
// ------------------------------------------------------------------------------------------------
// we re-export the artifacts, so they are easily available from the alias
// hardhat-deploy 2 writes one module per contract under generated/artifacts/, re-exported by its index
import * as artifacts from "./generated/artifacts/index.js";
export { artifacts };
// ------------------------------------------------------------------------------------------------
// rocketh 0.19: build the typed deployScript helper from the extensions
import { setupDeployScripts } from "rocketh";
const { deployScript } = setupDeployScripts<typeof extensions, typeof config.accounts, typeof config.data>(extensions);

// ------------------------------------------------------------------------------------------------
// we do the same for hardhat-deploy
import { setupHardhatDeploy } from "hardhat-deploy/helpers";
const { loadEnvironmentFromHardhat } = setupHardhatDeploy(extensions);
// ------------------------------------------------------------------------------------------------
// finally we export them
export { deployScript, loadEnvironmentFromHardhat };
