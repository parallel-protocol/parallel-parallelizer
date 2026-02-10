// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { GenericHarvester } from "contracts/helpers/GenericHarvester.sol";
import "contracts/utils/Errors.sol";
import { Fixture } from "../Fixture.sol";
import { MockFlashLoan } from "../mock/MockFlashLoan.sol";
import { MockRouterWithLeftovers } from "../mock/MockRouterWithLeftovers.sol";

/// @title GenericHarvester
contract Test_GenericHarvester is Fixture {
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
    MockRouterWithLeftovers maliciousRouter = _deployMaliciousRouter(7000);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(maliciousRouter),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));
  }

  /// @notice Verify leftover detection reverts with 50% consumption
  function test_RevertWhen_Router50PercentConsumption() public {
    MockRouterWithLeftovers router = _deployMaliciousRouter(5000);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(router),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));
  }

  /// @notice Verify leftover detection reverts with 90% consumption
  function test_RevertWhen_Router90PercentConsumption() public {
    MockRouterWithLeftovers router = _deployMaliciousRouter(9000);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(router),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));
  }

  /// @notice Verify leftover detection reverts with low consumption (1%)
  function test_RevertWhen_Router1PercentConsumption() public {
    MockRouterWithLeftovers router = _deployMaliciousRouter(100);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(router),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));
  }

  /// @notice Verify leftover detection catches even 0.1% leftover
  function test_RevertWhen_RouterLeavesMinimal0Point1Percent() public {
    MockRouterWithLeftovers almostGoodRouter = _deployMaliciousRouter(9990);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(almostGoodRouter),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));
  }

  /// @notice Verify leftover detection accepts 100% consumption
  function test_AcceptWhen_Router100PercentConsumption() public {
    MockRouterWithLeftovers goodRouter = _deployMaliciousRouter(10_000);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(goodRouter),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

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
    MockRouterWithLeftovers maliciousRouter = _deployMaliciousRouter(7000);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(maliciousRouter),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));

    assertEq(harvester.budget(alice), 10 ether);
  }

  /// @notice Verify exposures remain unchanged when harvest reverts
  function test_ExposuresUnchanged_WhenHarvestReverts() public {
    MockRouterWithLeftovers router = _deployMaliciousRouter(7000);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(router),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    (uint256 eurBBefore,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurABefore,) = parallelizer.getIssuedByCollateral(address(eurA));

    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));

    (uint256 eurBAfter,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurAAfter,) = parallelizer.getIssuedByCollateral(address(eurA));

    assertEq(eurBAfter, eurBBefore);
    assertEq(eurAAfter, eurABefore);
  }

  /// @notice Verify no swap tokens trapped in harvester when harvest reverts
  function test_NoSwapTokensTrapped_WhenHarvestReverts() public {
    MockRouterWithLeftovers router = _deployMaliciousRouter(7000);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(router),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));

    assertEq(IERC20(eurA).balanceOf(address(harvester)), 0, "eurA should not be trapped");
    assertEq(IERC20(eurB).balanceOf(address(harvester)), 0, "eurB should not be trapped");
  }

  /// @notice Verify flash loan is repaid when harvest reverts
  function test_FlashLoanRepaid_WhenHarvestReverts() public {
    MockRouterWithLeftovers router = _deployMaliciousRouter(7000);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(router),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    uint256 flashLoanBalanceBefore = IERC20(tokenP).balanceOf(address(flashLoan));

    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));

    assertEq(IERC20(tokenP).balanceOf(address(flashLoan)), flashLoanBalanceBefore);
  }

  /*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                PARAMETER VALIDATION TESTS
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

  /// @notice Verify harvest reverts when scale exceeds maximum (1e9)
  function test_RevertWhen_ScaleExceedsMaximum() public {
    MockRouterWithLeftovers goodRouter = _deployMaliciousRouter(10_000);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(goodRouter),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.prank(alice);
    vm.expectRevert(InvalidParam.selector);
    harvester.harvest(address(eurB), 1e9 + 1, _createSwapData(address(eurB), address(eurA)));
  }

  /// @notice Verify harvest succeeds with maximum valid scale (1e9 = 100%)
  function test_SuccessWhen_ScaleIsMaximum() public {
    MockRouterWithLeftovers goodRouter = _deployMaliciousRouter(10_000);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(goodRouter),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

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
    MockRouterWithLeftovers goodRouter = _deployMaliciousRouter(10_000);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(goodRouter),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    // Capture state before
    (uint256 eurBBefore,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurABefore,) = parallelizer.getIssuedByCollateral(address(eurA));

    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));

    // Verify state changed
    (uint256 eurBAfter,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurAAfter,) = parallelizer.getIssuedByCollateral(address(eurA));

    assertLt(eurBAfter, eurBBefore, "eurB should decrease");
    assertGt(eurAAfter, eurABefore, "eurA should increase");
  }

  function test_RevertWhen_ScaleIsZero() public {
    MockRouterWithLeftovers goodRouter = _deployMaliciousRouter(10_000);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(goodRouter),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    vm.prank(alice);
    vm.expectRevert(ZeroAmount.selector);
    harvester.harvest(address(eurB), 0, _createSwapData(address(eurB), address(eurA)));
  }

  /*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                ACCESS CONTROL TESTS
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

  /// @notice Verify only authorized can set swap router
  function test_RevertWhen_UnauthorizedSetsSwapRouter() public {
    MockRouterWithLeftovers router = _deployMaliciousRouter(10_000);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(router),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

    vm.prank(alice);
    vm.expectRevert(abi.encodeWithSelector(AccessManagedUnauthorized.selector, alice));
    harvester.setSwapRouter(address(router));
  }

  /// @notice Verify only authorized can set token transfer address
  function test_RevertWhen_UnauthorizedSetsTokenTransfer() public {
    MockRouterWithLeftovers router = _deployMaliciousRouter(10_000);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(router),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

    vm.prank(alice);
    vm.expectRevert(abi.encodeWithSelector(AccessManagedUnauthorized.selector, alice));
    harvester.setTokenTransferAddress(address(0x123));
  }

  /*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                BUDGET MANAGEMENT TESTS
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

  /// @notice Verify removeBudget reverts with insufficient balance
  function test_RevertWhen_RemoveBudgetInsufficientBalance() public {
    MockRouterWithLeftovers router = _deployMaliciousRouter(10_000);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(router),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);

    vm.prank(alice);
    vm.expectRevert();
    harvester.removeBudget(20 ether, alice);
  }

  /// @notice Verify addBudget and removeBudget workflow
  function test_BudgetManagementWorkflow() public {
    MockRouterWithLeftovers router = _deployMaliciousRouter(10_000);
    GenericHarvester harvester = _deployAndConfigureHarvester(
      address(router),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

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
}
