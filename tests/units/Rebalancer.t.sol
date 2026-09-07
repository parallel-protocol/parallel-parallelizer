// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.28;

import { MultiBlockRebalancer } from "contracts/helpers/MultiBlockRebalancer.sol";
import { IParallelizer } from "contracts/interfaces/IParallelizer.sol";
import "contracts/utils/Constants.sol";
import "contracts/utils/Errors.sol" as Errors;

import { Fixture } from "../Fixture.sol";

contract Test_Rebalancer_MaxSlippage is Fixture {
  MultiBlockRebalancer internal rebalancer;

  address internal yieldBearingAsset;

  function setUp() public override {
    super.setUp();

    yieldBearingAsset = address(eurY);
    rebalancer = new MultiBlockRebalancer(address(accessManager), tokenP, IParallelizer(address(parallelizer)));

    vm.startPrank(governor);
    accessManager.setTargetFunctionRole(
      address(rebalancer), getGuardianBaseRebalancerSelectorAccess(), GUARDIAN_ROLE
    );
    accessManager.grantRole(GUARDIAN_ROLE, guardian, 0);
    vm.stopPrank();

    vm.prank(guardian);
    rebalancer.setYieldBearingAssetData(yieldBearingAsset, address(eurA), 5e8, 1e8, 9e8, 1, 5e7);
  }

  function test_SetMaxSlippage_UpdatesTheLiveLimit() public {
    vm.prank(guardian);
    rebalancer.setMaxSlippage(yieldBearingAsset, 1e7);

    (,,,,, uint96 maxSlippage) = rebalancer.yieldBearingData(yieldBearingAsset);
    assertEq(maxSlippage, 1e7);
  }

  function test_RevertWhen_SetMaxSlippageIsFullSlippage() public {
    vm.prank(guardian);
    vm.expectRevert(Errors.InvalidParam.selector);
    rebalancer.setMaxSlippage(yieldBearingAsset, 1e9);
  }

  function test_RevertWhen_SetMaxSlippageNotGuardian() public {
    vm.prank(alice);
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    rebalancer.setMaxSlippage(yieldBearingAsset, 1e7);
  }
}
