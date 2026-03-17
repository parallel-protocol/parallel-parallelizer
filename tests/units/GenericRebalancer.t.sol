// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { GenericRebalancer } from "contracts/helpers/GenericRebalancer.sol";
import {
  AccessManagedUnauthorized,
  InvalidParam,
  NotTrusted,
  RouterDidNotConsumeAllTokens,
  ZeroAmount
} from "contracts/utils/Errors.sol";
import { Fixture } from "../Fixture.sol";
import { MockFlashLoan } from "../mock/MockFlashLoan.sol";

/// @title Test_GenericRebalancer
contract Test_GenericRebalancer is Fixture {
  MockFlashLoan public flashLoan;

  function setUp() public override {
    super.setUp();
    flashLoan = _deployFlashLoan(address(tokenP));
  }

  /*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                              LEFTOVER DETECTION TESTS
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

  /// @notice Verify leftover detection reverts with 70% consumption
  function test_RevertWhen_Router70PercentConsumption() public {
    GenericRebalancer harvester = _deployHarvester(7000);
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.prank(alice);
    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));
  }

  /// @notice Verify leftover detection reverts with 50% consumption
  function test_RevertWhen_Router50PercentConsumption() public {
    GenericRebalancer harvester = _deployHarvester(5000);
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.prank(alice);
    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));
  }

  /// @notice Verify leftover detection reverts with 90% consumption
  function test_RevertWhen_Router90PercentConsumption() public {
    GenericRebalancer harvester = _deployHarvester(9000);
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.prank(alice);
    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));
  }

  /// @notice Verify leftover detection reverts with low consumption (1%)
  function test_RevertWhen_Router1PercentConsumption() public {
    GenericRebalancer harvester = _deployHarvester(100);
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.prank(alice);
    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));
  }

  /// @notice Verify leftover detection catches even 0.1% leftover
  function test_RevertWhen_RouterLeavesMinimal0Point1Percent() public {
    GenericRebalancer harvester = _deployHarvester(9990);
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.prank(alice);
    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));
  }

  /// @notice Verify leftover detection accepts 100% consumption
  function test_AcceptWhen_Router100PercentConsumption() public {
    GenericRebalancer harvester = _deployHarvester(10_000);
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));
  }

  /*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                              STATE VERIFICATION TESTS
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

  /// @notice Verify budget protection when harvest reverts
  function test_BudgetProtected_WhenHarvestReverts() public {
    GenericRebalancer harvester = _deployHarvester(7000);
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.prank(alice);
    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));

    assertEq(harvester.budget(alice), 10 ether);
  }

  /// @notice Verify exposures remain unchanged when harvest reverts
  function test_ExposuresUnchanged_WhenHarvestReverts() public {
    GenericRebalancer harvester = _deployHarvester(7000);
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    (uint256 eurBBefore,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurABefore,) = parallelizer.getIssuedByCollateral(address(eurA));

    vm.prank(alice);
    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));

    (uint256 eurBAfter,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurAAfter,) = parallelizer.getIssuedByCollateral(address(eurA));

    assertEq(eurBAfter, eurBBefore);
    assertEq(eurAAfter, eurABefore);
  }

  /// @notice Verify no swap tokens trapped in harvester when harvest reverts
  function test_NoSwapTokensTrapped_WhenHarvestReverts() public {
    GenericRebalancer harvester = _deployHarvester(7000);
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.prank(alice);
    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));

    assertEq(IERC20(eurA).balanceOf(address(harvester)), 0, "eurA should not be trapped");
    assertEq(IERC20(eurB).balanceOf(address(harvester)), 0, "eurB should not be trapped");
  }

  /// @notice Verify flash loan is repaid when harvest reverts
  function test_FlashLoanRepaid_WhenHarvestReverts() public {
    GenericRebalancer harvester = _deployHarvester(7000);
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    uint256 flashLoanBalanceBefore = IERC20(tokenP).balanceOf(address(flashLoan));

    vm.prank(alice);
    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));

    assertEq(IERC20(tokenP).balanceOf(address(flashLoan)), flashLoanBalanceBefore);
  }

  /*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                              FLASH LOAN GUARD TESTS
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

  /// @notice Verify onFlashLoan reverts when called by an unauthorized address
  function test_RevertWhen_OnFlashLoanCalledByNonFlashLoan() public {
    GenericRebalancer harvester = _deployHarvester(10_000);

    vm.prank(alice);
    vm.expectRevert(NotTrusted.selector);
    harvester.onFlashLoan(address(harvester), address(tokenP), 0, 0, "");
  }

  /// @notice Verify onFlashLoan reverts when called with a wrong initiator
  function test_RevertWhen_OnFlashLoanCalledWithWrongInitiator() public {
    GenericRebalancer harvester = _deployHarvester(10_000);

    vm.prank(address(flashLoan));
    vm.expectRevert(NotTrusted.selector);
    harvester.onFlashLoan(alice, address(tokenP), 0, 0, "");
  }

  /// @notice Verify onFlashLoan reverts when called with a non-zero fee
  function test_RevertWhen_OnFlashLoanCalledWithNonZeroFee() public {
    GenericRebalancer harvester = _deployHarvester(10_000);

    vm.prank(address(flashLoan));
    vm.expectRevert(NotTrusted.selector);
    harvester.onFlashLoan(address(harvester), address(tokenP), 0, 1, "");
  }

  /*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                              PARAMETER VALIDATION TESTS
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

  /// @notice Verify harvest reverts when scale exceeds maximum (1e9)
  function test_RevertWhen_ScaleExceedsMaximum() public {
    GenericRebalancer harvester = _deployHarvester(10_000);

    vm.prank(alice);
    vm.expectRevert(InvalidParam.selector);
    harvester.harvest(address(eurB), 1e9 + 1, _createSwapData(address(eurB), address(eurA)));
  }

  /// @notice Verify harvest succeeds with maximum valid scale (1e9 = 100%)
  function test_SuccessWhen_ScaleIsMaximum() public {
    GenericRebalancer harvester = _deployHarvester(10_000);
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    (uint256 eurBBefore,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurABefore,) = parallelizer.getIssuedByCollateral(address(eurA));

    vm.prank(alice);
    harvester.harvest(address(eurB), 1e9, _createSwapData(address(eurB), address(eurA)));

    (uint256 eurBAfter,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurAAfter,) = parallelizer.getIssuedByCollateral(address(eurA));

    assertLt(eurBAfter, eurBBefore, "eurB exposure should decrease");
    assertGt(eurAAfter, eurABefore, "eurA exposure should increase");
  }

  /// @notice Verify harvest succeeds with partial scale (50%)
  function test_SuccessWhen_ScaleIsPartial() public {
    GenericRebalancer harvester = _deployHarvester(10_000);
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    (uint256 eurBBefore,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurABefore,) = parallelizer.getIssuedByCollateral(address(eurA));

    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));

    (uint256 eurBAfter,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurAAfter,) = parallelizer.getIssuedByCollateral(address(eurA));

    assertLt(eurBAfter, eurBBefore, "eurB should decrease");
    assertGt(eurAAfter, eurABefore, "eurA should increase");
  }

  /// @notice Verify harvest reverts when scale is zero
  function test_RevertWhen_ScaleIsZero() public {
    GenericRebalancer harvester = _deployHarvester(10_000);
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.prank(alice);
    vm.expectRevert(ZeroAmount.selector);
    harvester.harvest(address(eurB), 0, _createSwapData(address(eurB), address(eurA)));
  }

  /*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                              REBALANCING DIRECTION TESTS
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

  /// @notice Verify harvest increases eurB exposure when eurB is under-exposed (typeAction == 1)
  /// @dev eurY holds 50% of system to keep eurA and eurB in the low-fee exposure zone:
  ///      eurY=400e18 (50%), eurA=300e18 (37.5%), eurB=100e18 (12.5% < 50% target -> increase)
  function test_SuccessWhen_IncreaseExposureBranch() public {
    GenericRebalancer harvester = _deployHarvester(10_000);
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurY), 400e18, 410e18);
    _mintExactOutput(bob, address(eurA), 300e18, 330e6);
    _mintExactOutput(bob, address(eurB), 100e18, 110e12);

    (uint256 eurBBefore,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurABefore,) = parallelizer.getIssuedByCollateral(address(eurA));

    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurA), address(eurB), 12e12));

    (uint256 eurBAfter,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurAAfter,) = parallelizer.getIssuedByCollateral(address(eurA));

    assertGt(eurBAfter, eurBBefore, "eurB exposure should increase");
    assertLt(eurAAfter, eurABefore, "eurA exposure should decrease");
  }

  /*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                              ACCESS CONTROL TESTS
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

  /// @notice Verify only authorized can set swap router
  function test_RevertWhen_UnauthorizedSetsSwapRouter() public {
    GenericRebalancer harvester = _deployHarvester(10_000);

    vm.prank(alice);
    vm.expectRevert(abi.encodeWithSelector(AccessManagedUnauthorized.selector, alice));
    harvester.setSwapRouter(address(0x123));
  }

  /// @notice Verify only authorized can set token transfer address
  function test_RevertWhen_UnauthorizedSetsTokenTransfer() public {
    GenericRebalancer harvester = _deployHarvester(10_000);

    vm.prank(alice);
    vm.expectRevert(abi.encodeWithSelector(AccessManagedUnauthorized.selector, alice));
    harvester.setTokenTransferAddress(address(0x123));
  }

  /*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                              BUDGET MANAGEMENT TESTS
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

  /// @notice Verify removeBudget reverts with insufficient balance
  function test_RevertWhen_RemoveBudgetInsufficientBalance() public {
    GenericRebalancer harvester = _deployHarvester(10_000);
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);

    vm.prank(alice);
    vm.expectRevert();
    harvester.removeBudget(20 ether, alice);
  }

  /// @notice Verify budget is credited when the swap produces a surplus over the flash loan amount
  /// @dev 600e18 from eurB (60%) + 400e18 from eurA (40%), total 1000e18 tokenP
  ///      Rebalancer computes flash loan ~25 tokenP. Router returns 30 eurA -> ~29.6 tokenP minted -> surplus
  function test_BudgetCredited_WhenSwapProducesExcess() public {
    GenericRebalancer harvester = _deployHarvester(10_000);
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 600e18, 700e12);
    _mintExactOutput(bob, address(eurA), 400e18, 420e6);

    uint256 budgetBefore = harvester.budget(alice);

    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA), 30e6));

    assertGt(harvester.budget(alice), budgetBefore, "budget should increase when swap produces excess");
  }

  /// @notice Verify budget is debited when the swap produces a shortfall under the flash loan amount
  /// @dev 600/400 collateral split as the surplus test
  ///      Router returns 25 eurA -> ~24.65 tokenP minted, within 3% slippage floor -> deficit deducted from budget
  function test_BudgetDebited_WhenSwapProducesDeficit() public {
    GenericRebalancer harvester = _deployHarvester(10_000);
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 600e18, 700e12);
    _mintExactOutput(bob, address(eurA), 400e18, 420e6);

    uint256 budgetBefore = harvester.budget(alice);

    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA), 25e6));

    assertLt(harvester.budget(alice), budgetBefore, "budget should decrease when swap produces shortfall");
  }

  /// @notice Verify harvest reverts when budget is insufficient to cover the swap deficit
  function test_RevertWhen_BudgetInsufficientForDeficit() public {
    GenericRebalancer harvester = _deployHarvester(10_000);
    _setupUserBudget(harvester, alice, address(tokenP), 0.1 ether);
    _mintExactOutput(bob, address(eurB), 600e18, 700e12);
    _mintExactOutput(bob, address(eurA), 400e18, 420e6);

    vm.prank(alice);
    vm.expectRevert();
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA), 25e6));
  }

  /// @notice Verify addBudget and removeBudget workflow
  function test_BudgetManagementWorkflow() public {
    GenericRebalancer harvester = _deployHarvester(10_000);

    deal(address(tokenP), alice, 100 ether);
    vm.startPrank(alice);
    IERC20(tokenP).approve(address(harvester), 100 ether);

    harvester.addBudget(10 ether, alice);
    assertEq(harvester.budget(alice), 10 ether);

    harvester.removeBudget(5 ether, alice);
    assertEq(harvester.budget(alice), 5 ether);
    assertEq(IERC20(tokenP).balanceOf(alice), 95 ether);

    vm.stopPrank();
  }

  /*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                              PRIVATE HELPERS
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

  /// @dev Deploys a harvester bound to this fixture's parallelizer, using a router with the given consumption rate.
  /// @param consumptionRate Router consumption rate in basis points (10_000 = 100%, no leftovers)
  function _deployHarvester(uint256 consumptionRate) private returns (GenericRebalancer) {
    return _deployAndConfigureHarvester(
      address(_deployMaliciousRouter(consumptionRate)),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );
  }
}