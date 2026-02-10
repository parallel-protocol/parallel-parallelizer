// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Test } from "@forge-std/Test.sol";

import { GenericHarvester, SwapType } from "contracts/helpers/GenericHarvester.sol";
import { BaseHarvester } from "contracts/helpers/BaseHarvester.sol";
import { ITokenP } from "contracts/interfaces/ITokenP.sol";
import { IParallelizer } from "contracts/interfaces/IParallelizer.sol";
import { MockRouterWithLeftovers } from "../mock/MockRouterWithLeftovers.sol";
import { MockFlashLoan } from "../mock/MockFlashLoan.sol";

/// @title GenericHarvesterUtils
/// @notice Utility functions for GenericHarvester testing

abstract contract GenericHarvesterUtils is Test {
  /// @notice Deploy a flash loan contract
  /// @param tokenP Address of the tokenP
  /// @return flashLoan The deployed flash loan contract
  function _deployFlashLoan(address tokenP) internal returns (MockFlashLoan flashLoan) {
    flashLoan = new MockFlashLoan(tokenP);
    deal(tokenP, address(flashLoan), 1000 ether);
  }

  /// @notice Deploy and configure a GenericHarvester with a given router
  /// @param router Address of the swap router
  /// @param tokenP Address of the tokenP
  /// @param parallelizer Address of the parallelizer
  /// @param accessManager Address of the access manager
  /// @param flashLoan Address of the flash loan contract
  /// @param governor Address with governor role
  /// @param guardian Address with guardian role
  /// @param eurA Address of eurA token
  /// @param eurB Address of eurB token
  /// @return harvester The deployed and configured harvester
  function _deployAndConfigureHarvester(
    address router,
    address tokenP,
    address parallelizer,
    address accessManager,
    address flashLoan,
    address governor,
    address guardian,
    address eurA,
    address eurB
  )
    internal
    returns (GenericHarvester harvester)
  {
    // Fund router with both tokens
    deal(eurA, router, 1000 ether);
    deal(eurB, router, 1000 ether);

    // Deploy harvester
    vm.prank(governor);
    harvester = new GenericHarvester(
      router, router, ITokenP(tokenP), IParallelizer(parallelizer), accessManager, MockFlashLoan(flashLoan)
    );

    // Setup permissions
    vm.startPrank(governor);
    bytes4[] memory selectors = new bytes4[](3);
    selectors[0] = BaseHarvester.setYieldBearingAssetData.selector;
    selectors[1] = GenericHarvester.setSwapRouter.selector;
    selectors[2] = GenericHarvester.setTokenTransferAddress.selector;

    // Call accessManager.setTargetFunctionRole directly
    (bool success,) = accessManager.call(
      abi.encodeWithSignature(
        "setTargetFunctionRole(address,bytes4[],uint64)",
        address(harvester),
        selectors,
        uint64(20) // GUARDIAN_ROLE
      )
    );
    require(success, "Failed to set permissions");
    vm.stopPrank();

    // Configure yield bearing asset with default parameters
    vm.prank(guardian);
    harvester.setYieldBearingAssetData(
      eurB, // yieldBearingAsset
      eurA, // depositAsset
      5e8, // targetExposure (50%)
      3e8, // minExposure (30%)
      7e8, // maxExposure (70%)
      1e8, // maxSlippage (10%)
      3e7 // maxGasExpense (30M wei)
    );
  }

  /// @notice Setup user budget in the harvester
  /// @param harvester The harvester contract
  /// @param user Address of the user
  /// @param tokenP Address of tokenP
  /// @param budgetAmount Amount of budget to add
  function _setupUserBudget(GenericHarvester harvester, address user, address tokenP, uint256 budgetAmount) internal {
    deal(tokenP, user, budgetAmount * 10); // Give 10x for approval
    vm.startPrank(user);
    IERC20(tokenP).approve(address(harvester), budgetAmount * 10);
    harvester.addBudget(budgetAmount, user);
    vm.stopPrank();
  }

  /// @notice Create swap data for harvest
  /// @param eurB Address of eurB token
  /// @param eurA Address of eurA token
  /// @return extraData Encoded swap data
  function _createSwapData(address eurB, address eurA) internal pure returns (bytes memory extraData) {
    bytes memory swapData = abi.encodeWithSelector(
      bytes4(keccak256("swap(uint256,address,uint256,address)")),
      1_500_000, // amountIn
      eurB, // tokenIn
      1_500_000, // amountOut
      eurA // tokenOut
    );
    extraData = abi.encode(SwapType.SWAP, swapData);
  }

  /// @notice Deploy a malicious router with configurable consumption rate
  /// @param consumptionRate Consumption rate in basis points (7000 = 70%)
  /// @return router The deployed malicious router
  function _deployMaliciousRouter(uint256 consumptionRate) internal returns (MockRouterWithLeftovers router) {
    router = new MockRouterWithLeftovers(consumptionRate);
  }
}
