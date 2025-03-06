// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

import { stdError } from "@forge-std/Test.sol";

import { MockOneInchRouter } from "tests/mock/MockOneInchRouter.sol";
import { MockTokenPermit } from "tests/mock/MockTokenPermit.sol";

import "contracts/parallelizer/Storage.sol";
import "contracts/utils/Errors.sol" as Errors;

import "../Fixture.sol";

contract RewardHandlerTest is Fixture {
  event RewardsSoldFor(address indexed tokenObtained, uint256 balanceUpdate);

  MockOneInchRouter oneInch;
  IERC20 tokenA;
  IERC20 tokenB;

  function setUp() public override {
    super.setUp();
    oneInch = MockOneInchRouter(0x1111111254EEB25477B68fb85Ed929f73A960582);

    tokenA = IERC20(address(new MockTokenPermit("tokenA", "tokenA", 18)));
    tokenB = IERC20(address(new MockTokenPermit("tokenA", "tokenA", 9)));

    MockOneInchRouter tempRouter = new MockOneInchRouter();
    vm.etch(address(oneInch), address(tempRouter).code);
  }

  function test_RevertWhen_SellRewards_NotTrusted() public {
    startHoax(alice);
    vm.expectRevert(Errors.NotTrusted.selector);
    bytes memory data;
    parallelizer.sellRewards(0, data);
  }

  function test_RevertWhen_SellRewards_NoApproval() public {
    vm.startPrank(guardian);
    bytes memory payload =
      abi.encodeWithSelector(MockOneInchRouter.swap.selector, 100, 100, address(tokenA), address(tokenB));
    vm.expectRevert();
    parallelizer.sellRewards(0, payload);
    vm.stopPrank();
  }

  function test_RevertWhen_SellRewards_NoIncrease() public {
    bytes memory payload =
      abi.encodeWithSelector(MockOneInchRouter.swap.selector, 100, 100, address(tokenA), address(tokenB));
    vm.startPrank(governor);

    deal(address(tokenA), address(parallelizer), 100);
    deal(address(tokenB), address(oneInch), 100);
    parallelizer.changeAllowance(tokenA, address(oneInch), 100);
    vm.expectRevert(Errors.InvalidSwap.selector);
    parallelizer.sellRewards(0, payload);
    vm.stopPrank();
  }

  function test_RevertWhen_SellRewards_TooSmallAmountOut() public {
    bytes memory payload =
      abi.encodeWithSelector(MockOneInchRouter.swap.selector, 100, 100, address(tokenA), address(tokenB));
    vm.startPrank(governor);

    deal(address(tokenA), address(parallelizer), 100);
    deal(address(tokenB), address(oneInch), 100);
    parallelizer.changeAllowance(tokenA, address(oneInch), 100);
    vm.expectRevert(Errors.TooSmallAmountOut.selector);
    parallelizer.sellRewards(1000, payload);
    vm.stopPrank();
  }

  function test_RevertWhen_SellRewards_EmptyErrorMessage() public {
    bytes memory payload =
      abi.encodeWithSelector(MockOneInchRouter.swap.selector, 100, 100, address(tokenA), address(tokenB));
    vm.startPrank(governor);

    deal(address(tokenA), address(parallelizer), 100);
    deal(address(tokenB), address(oneInch), 100);
    parallelizer.changeAllowance(tokenA, address(oneInch), 100);
    oneInch.setRevertStatuses(true, false);
    vm.expectRevert(Errors.OneInchSwapFailed.selector);
    parallelizer.sellRewards(0, payload);
    vm.stopPrank();
  }

  function test_RevertWhen_SellRewards_ErrorMessage() public {
    bytes memory payload =
      abi.encodeWithSelector(MockOneInchRouter.swap.selector, 100, 100, address(tokenA), address(tokenB));
    vm.startPrank(governor);

    deal(address(tokenA), address(parallelizer), 100);
    deal(address(tokenB), address(oneInch), 100);
    parallelizer.changeAllowance(tokenA, address(oneInch), 100);
    oneInch.setRevertStatuses(false, true);
    vm.expectRevert("wrong swap");
    parallelizer.sellRewards(0, payload);
    vm.stopPrank();
  }

  function test_RevertWhen_SellRewards_InvalidSwapBecauseTokenSold() public {
    bytes memory payload =
      abi.encodeWithSelector(MockOneInchRouter.swap.selector, 100, 100, address(eurA), address(eurB));
    vm.startPrank(governor);

    deal(address(eurA), address(parallelizer), 100);
    deal(address(eurB), address(oneInch), 100);
    parallelizer.changeAllowance(eurA, address(oneInch), 100);
    vm.expectRevert(Errors.InvalidSwap.selector);
    parallelizer.sellRewards(0, payload);
    vm.stopPrank();
  }

  function test_SellRewards_WithOneTokenIncrease() public {
    bytes memory payload =
      abi.encodeWithSelector(MockOneInchRouter.swap.selector, 100, 100, address(tokenA), address(eurA));
    vm.startPrank(governor);

    deal(address(tokenA), address(parallelizer), 100);
    deal(address(eurA), address(oneInch), 100);
    parallelizer.changeAllowance(tokenA, address(oneInch), 100);
    vm.expectEmit(address(parallelizer));
    emit RewardsSoldFor(address(eurA), 100);
    parallelizer.sellRewards(0, payload);
    vm.stopPrank();
  }

  function test_SellRewards_WithOneTokenIncreaseAndTrusted() public {
    bytes memory payload =
      abi.encodeWithSelector(MockOneInchRouter.swap.selector, 100, 100, address(tokenA), address(eurA));
    vm.startPrank(governor);
    parallelizer.toggleTrusted(alice, TrustedType.Seller);
    parallelizer.changeAllowance(tokenA, address(oneInch), 100);
    vm.stopPrank();

    deal(address(tokenA), address(parallelizer), 100);
    deal(address(eurA), address(oneInch), 100);

    vm.expectEmit(address(parallelizer));
    emit RewardsSoldFor(address(eurA), 100);
    vm.prank(alice);
    parallelizer.sellRewards(0, payload);
  }
}
