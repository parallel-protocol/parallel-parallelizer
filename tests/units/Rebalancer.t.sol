// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.28;

import { MultiBlockRebalancer } from "contracts/helpers/MultiBlockRebalancer.sol";
import { GenericRebalancer, SwapType } from "contracts/helpers/GenericRebalancer.sol";
import { IERC3156FlashLender } from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { MockRouter } from "../mock/MockRouter.sol";
import { MockFlashLoan } from "../mock/MockFlashLoan.sol";
import { MockTokenPermit } from "../mock/MockTokenPermit.sol";
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


contract Test_Rebalancer_ResidualInput is Fixture {
  GenericRebalancer internal rebalancer;
  MockRouter internal router;
  MockFlashLoan internal lender;

  function setUp() public override {
    super.setUp();

    router = new MockRouter();
    lender = new MockFlashLoan();
    rebalancer = new GenericRebalancer(
      address(router), address(router), tokenP, parallelizer, address(accessManager), IERC3156FlashLender(address(lender))
    );

    vm.startPrank(governor);
    accessManager.setTargetFunctionRole(
      address(rebalancer), getGuardianBaseRebalancerSelectorAccess(), GUARDIAN_ROLE
    );
    accessManager.grantRole(GUARDIAN_ROLE, guardian, 0);
    vm.stopPrank();

    // eurY is the yield bearing asset, eurA its underlying. Target exposure well below the live one
    // so the rebalance decreases eurY and the router leg runs with eurY as the input.
    vm.startPrank(guardian);
    rebalancer.toggleTrusted(alice);
    rebalancer.setYieldBearingAssetData(address(eurY), address(eurA), 2e8, 1e7, 9e8, 1, 5e8);
    vm.stopPrank();

    _mintCollateral(address(eurY), 100_000 ether);
    _mintCollateral(address(eurA), 1000 * BASE_6);

    // The router needs the output leg to hand back, and alice a budget to settle against
    deal(address(eurA), address(router), 1_000_000 * BASE_6);
    deal(address(tokenP), alice, 100_000 ether);
    vm.startPrank(alice);
    IERC20(address(tokenP)).approve(address(rebalancer), type(uint256).max);
    rebalancer.addBudget(50_000 ether, alice);
    vm.stopPrank();
  }

  function _mintCollateral(address collateral, uint256 amount) internal {
    deal(collateral, governor, amount);
    vm.startPrank(governor);
    IERC20(collateral).approve(address(parallelizer), amount);
    parallelizer.swapExactInput(amount, 0, collateral, address(tokenP), governor, block.timestamp + 1 hours);
    vm.stopPrank();
  }

  /// @dev The route consumes less input than it was offered: the remainder must come back rather
  /// than sit on the rebalancer, and no router allowance may survive the call.
  function test_Harvest_ReturnsInputTheRouteDidNotConsume() public {
    uint256 consumed = 1 ether;
    bytes memory swapData = abi.encodeWithSelector(
      MockRouter.swap.selector, consumed, address(eurY), 5000 * BASE_6, address(eurA)
    );

    uint256 budgetBefore = rebalancer.budget(alice);

    vm.prank(alice);
    rebalancer.harvest(address(eurY), 1e7, abi.encode(SwapType.SWAP, swapData));

    assertEq(IERC20(address(eurY)).balanceOf(address(rebalancer)), 0, "input left stranded on the rebalancer");
    assertEq(IERC20(address(eurY)).allowance(address(rebalancer), address(router)), 0, "router allowance survived");
    // The recovered input settles with the operation, so the surplus reaches the initiating caller
    assertGt(rebalancer.budget(alice), budgetBefore, "settlement surplus not credited");
  }
}
