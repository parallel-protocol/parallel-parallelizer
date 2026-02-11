// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "./Base.s.sol";

import { GenericRebalancer } from "contracts/helpers/GenericRebalancer.sol";
import { BaseHarvester } from "contracts/helpers/BaseHarvester.sol";

contract SetGenericRebalancerRoles is BaseScript {
  address genericRebalancer = 0x57770C1721Eb35509f38210A935c8b1911db7E0e;

  function run() public broadcast {
    bytes4[] memory guardianSelectors = new bytes4[](5);
    guardianSelectors[0] = BaseHarvester.setYieldBearingAssetData.selector;
    guardianSelectors[1] = BaseHarvester.setMaxSlippage.selector;
    guardianSelectors[2] = BaseHarvester.toggleTrusted.selector;
    guardianSelectors[3] = BaseHarvester.recoverERC20.selector;
    guardianSelectors[4] = BaseHarvester.setTargetExposure.selector;
    accessManager.setTargetFunctionRole(genericRebalancer, guardianSelectors, Roles.GUARDIAN_ROLE);

    bytes4[] memory governorSelectors = new bytes4[](2);
    governorSelectors[0] = GenericRebalancer.setTokenTransferAddress.selector;
    governorSelectors[1] = GenericRebalancer.setSwapRouter.selector;
    accessManager.setTargetFunctionRole(genericRebalancer, governorSelectors, Roles.GOVERNOR_ROLE);
  }
}
