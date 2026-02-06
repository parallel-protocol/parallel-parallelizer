// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC3156FlashLender } from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import { IERC3156FlashBorrower } from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

import { GenericHarvester, SwapType } from "contracts/helpers/GenericHarvester.sol";
import { BaseHarvester } from "contracts/helpers/BaseHarvester.sol";

import "contracts/utils/Errors.sol";
import { Fixture } from "../Fixture.sol";

/// @notice Mock router that can simulate partial token consumption
contract MockRouterWithLeftovers {
  using SafeERC20 for IERC20;

  uint256 public consumptionRate;

  constructor(uint256 _rate) {
    consumptionRate = _rate;
  }

  function swap(uint256 amountIn, address tokenIn, uint256 amountOut, address tokenOut) external {
    uint256 toConsume = (amountIn * consumptionRate) / 10_000;
    IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), toConsume);
    IERC20(tokenOut).safeTransfer(msg.sender, amountOut);
  }
}

/// @notice Mock parallelizer for testing token transfers
contract MockParallelizer {
  using SafeERC20 for IERC20;

  function sendTokens(address token, address recipient, uint256 amount) external {
    IERC20(token).safeTransfer(recipient, amount);
  }
}

/// @notice Mock flash loan contract
contract MockFlashLoan is IERC3156FlashLender {
  IERC20 public immutable token;

  constructor(address _token) {
    token = IERC20(_token);
  }

  function maxFlashLoan(address _token) external view returns (uint256) {
    if (_token == address(token)) return type(uint256).max;
    return 0;
  }

  function flashFee(address _token, uint256) external pure returns (uint256) {
    require(_token != address(0), "Invalid token");
    return 0;
  }

  function flashLoan(
    IERC3156FlashBorrower receiver,
    address _token,
    uint256 amount,
    bytes calldata data
  )
    external
    returns (bool)
  {
    require(_token == address(token), "Unsupported token");

    token.transfer(address(receiver), amount);

    require(
      receiver.onFlashLoan(msg.sender, _token, amount, 0, data) == keccak256("ERC3156FlashBorrower.onFlashLoan"),
      "Callback failed"
    );

    token.transferFrom(address(receiver), address(this), amount);

    return true;
  }
}

/// @notice Test contract that implements leftover detection logic

contract LeftoverDetector {
  using SafeERC20 for IERC20;

  function swapWithLeftoverDetection(
    address tokenIn,
    address tokenOut,
    address mockParallelizer,
    address router,
    uint256 amountToReceive,
    uint256 amountToSwap,
    uint256 amountOut
  )
    external
  {
    uint256 tokenInBalanceBefore = IERC20(tokenIn).balanceOf(address(this));

    MockParallelizer(mockParallelizer).sendTokens(tokenIn, address(this), amountToReceive);

    IERC20(tokenIn).approve(router, amountToSwap);

    MockRouterWithLeftovers(router).swap(amountToSwap, tokenIn, amountOut, tokenOut);

    uint256 tokenInBalanceFinal = IERC20(tokenIn).balanceOf(address(this));
    if (tokenInBalanceFinal > tokenInBalanceBefore) {
      revert RouterDidNotConsumeAllTokens();
    }
  }
}

/// @title GenericHarvester Front-Run Protection Tests
/// @notice Tests for the leftover token detection mechanism that protects against front-running attacks
contract Test_GenericHarvester_FrontRunProtection is Fixture {
  // =============================================================
  //                        UNIT TESTS
  // =============================================================

  /// @notice Test that a malicious router consuming only 70% of tokens is detected
  function test_DetectsLeftoverTokens_70PercentConsumption() public {
    MockRouterWithLeftovers maliciousRouter = new MockRouterWithLeftovers(7000);
    MockParallelizer mockParallelizer = new MockParallelizer();
    LeftoverDetector detector = new LeftoverDetector();

    deal(address(eurA), address(mockParallelizer), 100 ether);
    deal(address(eurB), address(maliciousRouter), 50 ether);

    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    detector.swapWithLeftoverDetection(
      address(eurA), address(eurB), address(mockParallelizer), address(maliciousRouter), 100 ether, 100 ether, 50 ether
    );
  }

  /// @notice Test that a legitimate router consuming 100% of tokens is accepted
  function test_AcceptsFullConsumption_100Percent() public {
    MockRouterWithLeftovers goodRouter = new MockRouterWithLeftovers(10_000);
    MockParallelizer mockParallelizer = new MockParallelizer();
    LeftoverDetector detector = new LeftoverDetector();

    deal(address(eurA), address(mockParallelizer), 100 ether);
    deal(address(eurB), address(goodRouter), 50 ether);

    detector.swapWithLeftoverDetection(
      address(eurA), address(eurB), address(mockParallelizer), address(goodRouter), 100 ether, 100 ether, 50 ether
    );

    assertEq(IERC20(eurA).balanceOf(address(detector)), 0);
  }

  /// @notice Test that even a small leftover (0.1%) is detected
  function test_DetectsEvenSmallLeftover_99Point9Percent() public {
    MockRouterWithLeftovers almostGoodRouter = new MockRouterWithLeftovers(9990);
    MockParallelizer mockParallelizer = new MockParallelizer();
    LeftoverDetector detector = new LeftoverDetector();

    deal(address(eurA), address(mockParallelizer), 100 ether);
    deal(address(eurB), address(almostGoodRouter), 50 ether);

    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    detector.swapWithLeftoverDetection(
      address(eurA),
      address(eurB),
      address(mockParallelizer),
      address(almostGoodRouter),
      100 ether,
      100 ether,
      50 ether
    );
  }

  // =============================================================
  //                     INTEGRATION TEST
  // =============================================================

  /// @notice Integration test verifying that harvest reverts when a malicious router leaves leftover tokens
  /// @dev This test uses the complete harvest flow with flash loans and the Parallelizer
  function test_Integration_HarvestRevertsWithMaliciousRouter() public {
    // Setup flash loan contract
    MockFlashLoan flashLoan = new MockFlashLoan(address(tokenP));
    deal(address(tokenP), address(flashLoan), 1000 ether);

    // Deploy malicious router that only consumes 70% of tokens
    MockRouterWithLeftovers maliciousRouter = new MockRouterWithLeftovers(7000);
    deal(address(eurA), address(maliciousRouter), 1000 ether);
    deal(address(eurB), address(maliciousRouter), 1000 ether);

    // Deploy GenericHarvester
    vm.prank(governor);
    GenericHarvester harvester = new GenericHarvester(
      address(maliciousRouter), address(maliciousRouter), tokenP, parallelizer, address(accessManager), flashLoan
    );

    // Setup permissions
    vm.startPrank(governor);
    bytes4[] memory selectors = new bytes4[](3);
    selectors[0] = BaseHarvester.setYieldBearingAssetData.selector;
    selectors[1] = GenericHarvester.setSwapRouter.selector;
    selectors[2] = GenericHarvester.setTokenTransferAddress.selector;
    accessManager.setTargetFunctionRole(address(harvester), selectors, 20);
    vm.stopPrank();

    // Configure yield bearing asset
    vm.prank(guardian);
    harvester.setYieldBearingAssetData(address(eurB), address(eurA), 5e8, 3e8, 7e8, 1e8, 3e7);

    // Give budget to user
    deal(address(tokenP), alice, 100 ether);
    vm.startPrank(alice);
    tokenP.approve(address(harvester), 100 ether);
    harvester.addBudget(10 ether, alice);
    vm.stopPrank();

    // Setup unbalanced exposures (80% eurB, 20% eurA)
    _mintExactOutput(bob, address(eurB), 8e12, 8e12);
    _mintExactOutput(bob, address(eurA), 2e6, 2e6);

    // Prepare harvest data with realistic amounts
    bytes memory swapData = abi.encodeWithSelector(
      bytes4(keccak256("swap(uint256,address,uint256,address)")), 2_000_000, address(eurB), 2_000_000, address(eurA)
    );
    bytes memory extraData = abi.encode(SwapType.SWAP, swapData);

    // Harvest should revert when malicious router leaves leftover tokens
    vm.expectRevert(RouterDidNotConsumeAllTokens.selector);
    vm.prank(alice);
    harvester.harvest(address(eurB), 5e8, extraData);

    // User budget should remain unchanged (protected from loss)
    assertEq(harvester.budget(alice), 10 ether);
  }
}
