// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { GenericRebalancer } from "contracts/helpers/GenericRebalancer.sol";
import { RouterDidNotConsumeAllTokens } from "contracts/utils/Errors.sol";
import { Fixture } from "../Fixture.sol";
import { MockFlashLoan } from "../mock/MockFlashLoan.sol";

/// @title Test_GenericRebalancer_Integration
/// @notice End-to-end integration tests covering full harvest cycles and budget lifecycle
contract Test_GenericRebalancer_Integration is Fixture {
  MockFlashLoan public flashLoan;
  GenericRebalancer public harvester;

  function setUp() public override {
    super.setUp();
    flashLoan = _deployFlashLoan(address(tokenP));
    harvester = _deployAndConfigureHarvester(
      address(_deployMaliciousRouter(10_000)),
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

  /// @notice eurB over-exposed, harvest reduces it and increases eurA
  function test_HarvestSucceeds_DecreaseExposure() public {
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 600e18, 700e12);
    _mintExactOutput(bob, address(eurA), 400e18, 420e6);

    (uint256 eurBBefore,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurABefore,) = parallelizer.getIssuedByCollateral(address(eurA));

    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA), 28e6));

    (uint256 eurBAfter,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurAAfter,) = parallelizer.getIssuedByCollateral(address(eurA));

    assertLt(eurBAfter, eurBBefore, "eurB exposure should decrease");
    assertGt(eurAAfter, eurABefore, "eurA exposure should increase");
  }

  /// @notice Full harvest cycle: eurB under-exposed, harvest increases it and decreases eurA
  /// @dev eurY holds 50% of system to keep eurA and eurB in the low-fee exposure zone:
  ///      eurY=400e18 (50%), eurA=300e18 (37.5%), eurB=100e18 (12.5% < 50% target -> increase)
  function test_HarvestSucceeds_IncreaseExposure() public {
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

  /// @notice Complete budget lifecycle: add budget -> deficit harvest -> surplus harvest -> withdraw
  function test_BudgetLifecycle() public {
    _setupUserBudget(harvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 600e18, 700e12);
    _mintExactOutput(bob, address(eurA), 400e18, 420e6);

    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA), 25e6));
    uint256 budgetAfterDeficit = harvester.budget(alice);
    assertLt(budgetAfterDeficit, 10 ether, "budget should decrease after deficit harvest");

    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA), 30e6));
    uint256 budgetAfterSurplus = harvester.budget(alice);
    assertGt(budgetAfterSurplus, budgetAfterDeficit, "budget should increase after surplus harvest");

    vm.prank(alice);
    harvester.removeBudget(budgetAfterSurplus, alice);
    assertEq(harvester.budget(alice), 0, "budget should be empty after full withdrawal");
  }

  /// @notice Leftover tokens revert atomically: collateral exposures and budget are fully preserved
  function test_HarvestRevertsWhen_RouterLeavesLeftovers() public {
    GenericRebalancer maliciousHarvester = _deployAndConfigureHarvester(
      address(_deployMaliciousRouter(7000)),
      address(tokenP),
      address(parallelizer),
      address(accessManager),
      address(flashLoan),
      governor,
      guardian,
      address(eurA),
      address(eurB)
    );

    _setupUserBudget(maliciousHarvester, alice, address(tokenP), 10 ether);
    _mintExactOutput(bob, address(eurB), 600e18, 700e12);
    _mintExactOutput(bob, address(eurA), 400e18, 420e6);

    (uint256 eurBBefore,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurABefore,) = parallelizer.getIssuedByCollateral(address(eurA));
    uint256 budgetBefore = maliciousHarvester.budget(alice);

    vm.prank(alice);
    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    maliciousHarvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));

    (uint256 eurBAfter,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurAAfter,) = parallelizer.getIssuedByCollateral(address(eurA));
    assertEq(eurBAfter, eurBBefore, "eurB exposure should be unchanged");
    assertEq(eurAAfter, eurABefore, "eurA exposure should be unchanged");
    assertEq(maliciousHarvester.budget(alice), budgetBefore, "budget should be unchanged");
  }
}
