// ------------------------------------------------------------------------------------------------
// Typed Config
// ------------------------------------------------------------------------------------------------
import { UserConfig } from "rocketh";

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
// We regroup all what is needed for the deploy scripts
// so that they just need to import this file
// we add here the extension we need, so that they are available in the deploy scripts
// extensions are simply function that accept as their first argument the Environment
// by passing them to the setup function (see below) you get to access them trhough the environment object with type-safety
// we add here the module we need, so that they are available in the deploy scripts
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
import artifacts from "./generated/artifacts";
export { artifacts };
// ------------------------------------------------------------------------------------------------
// we create the rocketh function we need by passing the extensions
import { setup } from "rocketh";
const { deployScript, loadAndExecuteDeployments } = setup<
  typeof extensions,
  typeof config.accounts,
  typeof config.data
>(extensions);

// ------------------------------------------------------------------------------------------------
// we do the same for hardhat-deploy
import { setupHardhatDeploy } from "hardhat-deploy/helpers";
const { loadEnvironmentFromHardhat } = setupHardhatDeploy(extensions);
// ------------------------------------------------------------------------------------------------
// finally we export them
export { loadAndExecuteDeployments, deployScript, loadEnvironmentFromHardhat };
