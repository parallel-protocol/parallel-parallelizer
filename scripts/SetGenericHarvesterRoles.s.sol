// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "./Base.s.sol";

import { GenericHarvester } from "contracts/helpers/GenericHarvester.sol";
import { BaseHarvester } from "contracts/helpers/BaseHarvester.sol";

contract SetGenericHarvesterRoles is BaseScript {
  address genericHarvester = 0x57770C1721Eb35509f38210A935c8b1911db7E0e;

  function run() public broadcast {
    bytes4[] memory guardianSelectors = new bytes4[](5);
    guardianSelectors[0] = BaseHarvester.setYieldBearingAssetData.selector;
    guardianSelectors[1] = BaseHarvester.setMaxSlippage.selector;
    guardianSelectors[2] = BaseHarvester.toggleTrusted.selector;
    guardianSelectors[3] = BaseHarvester.recoverERC20.selector;
    guardianSelectors[4] = BaseHarvester.setTargetExposure.selector;
    accessManager.setTargetFunctionRole(genericHarvester, guardianSelectors, Roles.GUARDIAN_ROLE);

    bytes4[] memory governorSelectors = new bytes4[](2);
    governorSelectors[0] = GenericHarvester.setTokenTransferAddress.selector;
    governorSelectors[1] = GenericHarvester.setSwapRouter.selector;
    accessManager.setTargetFunctionRole(genericHarvester, governorSelectors, Roles.GOVERNOR_ROLE);
  }
}
