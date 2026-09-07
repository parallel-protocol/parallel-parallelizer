// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.28;

import { MultiBlockHarvester } from "contracts/helpers/MultiBlockHarvester.sol";
import { IParallelizer } from "contracts/interfaces/IParallelizer.sol";
import "contracts/utils/Constants.sol";
import "contracts/utils/Errors.sol" as Errors;

import { Fixture } from "../Fixture.sol";

contract Test_Harvester_MaxSlippage is Fixture {
  MultiBlockHarvester internal harvester;

  address internal yieldBearingAsset;

  function setUp() public override {
    super.setUp();

    yieldBearingAsset = address(eurY);
    harvester = new MultiBlockHarvester(address(accessManager), tokenP, IParallelizer(address(parallelizer)));

    vm.startPrank(governor);
    accessManager.setTargetFunctionRole(
      address(harvester), getGuardianBaseHarvesterSelectorAccess(), GUARDIAN_ROLE
    );
    accessManager.grantRole(GUARDIAN_ROLE, guardian, 0);
    vm.stopPrank();

    vm.prank(guardian);
    harvester.setYieldBearingAssetData(yieldBearingAsset, address(eurA), 5e8, 1e8, 9e8, 1, 5e7);
  }

  function test_SetMaxSlippage_UpdatesTheLiveLimit() public {
    vm.prank(guardian);
    harvester.setMaxSlippage(yieldBearingAsset, 1e7);

    (,,,,, uint96 maxSlippage) = harvester.yieldBearingData(yieldBearingAsset);
    assertEq(maxSlippage, 1e7);
  }

  function test_RevertWhen_SetMaxSlippageIsFullSlippage() public {
    vm.prank(guardian);
    vm.expectRevert(Errors.InvalidParam.selector);
    harvester.setMaxSlippage(yieldBearingAsset, 1e9);
  }

  function test_RevertWhen_SetMaxSlippageNotGuardian() public {
    vm.prank(alice);
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    harvester.setMaxSlippage(yieldBearingAsset, 1e7);
  }
}
