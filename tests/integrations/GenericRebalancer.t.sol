// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { GenericRebalancer } from "contracts/helpers/GenericRebalancer.sol";
import "contracts/utils/Errors.sol";
import { Fixture } from "../Fixture.sol";
import { MockRouterWithLeftovers } from "../mock/MockRouterWithLeftovers.sol";
import { MockFlashLoan } from "../mock/MockFlashLoan.sol";

/// @title GenericRebalancer
/// @notice End-to-end integration tests
contract Test_GenericRebalancer_Integration is Fixture {
  MockFlashLoan public flashLoan;

  function setUp() public override {
    super.setUp();
    flashLoan = _deployFlashLoan(address(tokenP));
  }

  /// @notice Reverts when router leaves 30% leftover
  function test_HarvestRevertsWhen_RouterLeavesLeftoverTokens() public {
    MockRouterWithLeftovers maliciousRouter = _deployMaliciousRouter(7000);
    GenericRebalancer harvester = _deployAndConfigureHarvester(
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

    // Harvest should revert when router leaves leftover tokens
    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));

    // User budget should remain unchanged (protected from loss)
    assertEq(harvester.budget(alice), 10 ether);
  }

  /// @notice When router consumes all tokens
  function test_HarvestSucceedsWhen_RouterConsumesAllTokens() public {
    // Deploy router that consumes 100% of tokens
    MockRouterWithLeftovers goodRouter = _deployMaliciousRouter(10_000);
    GenericRebalancer harvester = _deployAndConfigureHarvester(
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

    // Get exposures before harvest
    (uint256 eurBBefore,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurABefore,) = parallelizer.getIssuedByCollateral(address(eurA));

    // Harvest should succeed
    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));

    // Verify exposures (eurB decreased, eurA increased)
    (uint256 eurBAfter,) = parallelizer.getIssuedByCollateral(address(eurB));
    (uint256 eurAAfter,) = parallelizer.getIssuedByCollateral(address(eurA));

    assertLt(eurBAfter, eurBBefore, "eurB exposure should decrease");
    assertGt(eurAAfter, eurABefore, "eurA exposure should increase");
  }

  /// @notice Reverts with minimal 0.1% leftover
  function test_HarvestRevertsWhen_RouterLeavesMinimalLeftover() public {
    MockRouterWithLeftovers almostGoodRouter = _deployMaliciousRouter(9990);
    GenericRebalancer harvester = _deployAndConfigureHarvester(
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

    // Harvest should revert even with minimal leftover
    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, _createSwapData(address(eurB), address(eurA)));
  }
}
