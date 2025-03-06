// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.28;

import { stdError } from "@forge-std/Test.sol";

import "tests/mock/MockManager.sol";
import { MockKeyringGuard } from "tests/mock/MockKeyringGuard.sol";

import "contracts/parallelizer/Storage.sol";
import { Test } from "contracts/parallelizer/configs/Test.sol";
import { DiamondCut } from "contracts/parallelizer/facets/DiamondCut.sol";
import { LibSetters } from "contracts/parallelizer/libraries/LibSetters.sol";
import "contracts/utils/Constants.sol";
import "contracts/utils/Errors.sol" as Errors;

import { Fixture } from "../Fixture.sol";

contract Test_Setters_TogglePause is Fixture {
  function test_RevertWhen_NotGuardian() public {
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, governor));
    hoax(governor);
    parallelizer.togglePause(address(eurA), ActionType.Mint);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    hoax(alice);
    parallelizer.togglePause(address(eurA), ActionType.Mint);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, bob));
    hoax(bob);
    parallelizer.togglePause(address(eurA), ActionType.Mint);
  }

  function test_RevertWhen_NotCollateral() public {
    vm.expectRevert(Errors.NotCollateral.selector);
    hoax(guardian);
    parallelizer.togglePause(address(tokenP), ActionType.Mint);
  }

  function test_PauseMint() public {
    vm.expectEmit(address(parallelizer));
    emit LibSetters.PauseToggled(address(eurA), uint256(ActionType.Mint), true);

    hoax(guardian);
    parallelizer.togglePause(address(eurA), ActionType.Mint);

    assert(parallelizer.isPaused(address(eurA), ActionType.Mint));

    vm.expectRevert(Errors.Paused.selector);
    parallelizer.swapExactInput(1 ether, 1 ether, address(eurA), address(tokenP), alice, block.timestamp + 10);

    vm.expectRevert(Errors.Paused.selector);
    parallelizer.swapExactOutput(1 ether, 1 ether, address(eurA), address(tokenP), alice, block.timestamp + 10);
  }

  function test_PauseBurn() public {
    vm.expectEmit(address(parallelizer));
    emit LibSetters.PauseToggled(address(eurA), uint256(ActionType.Burn), true);

    hoax(guardian);
    parallelizer.togglePause(address(eurA), ActionType.Burn);

    assert(parallelizer.isPaused(address(eurA), ActionType.Burn));

    vm.expectRevert(Errors.Paused.selector);
    parallelizer.swapExactInput(1 ether, 1 ether, address(tokenP), address(eurA), alice, block.timestamp + 10);

    vm.expectRevert(Errors.Paused.selector);
    parallelizer.swapExactOutput(1 ether, 1 ether, address(tokenP), address(eurA), alice, block.timestamp + 10);
  }

  function test_PauseRedeem() public {
    vm.expectEmit(address(parallelizer));
    emit LibSetters.PauseToggled(address(eurA), uint256(ActionType.Redeem), true);

    hoax(guardian);
    parallelizer.togglePause(address(eurA), ActionType.Redeem);

    assert(parallelizer.isPaused(address(eurA), ActionType.Redeem));

    vm.expectRevert(Errors.Paused.selector);
    parallelizer.redeem(1 ether, alice, block.timestamp + 10, new uint256[](3));

    vm.expectRevert(Errors.Paused.selector);
    parallelizer.redeemWithForfeit(1 ether, alice, block.timestamp + 10, new uint256[](3), new address[](0));
  }
}

contract Test_Setters_SetFees is Fixture {
  function test_RevertWhen_NotGuardian() public {
    uint64[] memory xFee = new uint64[](3);
    int64[] memory yFee = new int64[](3);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, governor));
    hoax(governor);
    parallelizer.setFees(address(eurA), xFee, yFee, true);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    hoax(alice);
    parallelizer.setFees(address(eurA), xFee, yFee, true);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, bob));
    hoax(bob);
    parallelizer.setFees(address(eurA), xFee, yFee, true);
  }

  function test_RevertWhen_NotCollateral() public {
    uint64[] memory xFee = new uint64[](3);
    int64[] memory yFee = new int64[](3);

    vm.expectRevert(Errors.NotCollateral.selector);
    hoax(guardian);
    parallelizer.setFees(address(tokenP), xFee, yFee, true);
  }

  function test_RevertWhen_InvalidParamsLength0() public {
    uint64[] memory xFee = new uint64[](0);
    int64[] memory yFee = new int64[](0);

    vm.expectRevert(Errors.InvalidParams.selector);
    hoax(guardian);
    parallelizer.setFees(address(eurA), xFee, yFee, true);
  }

  function test_RevertWhen_InvalidParamsDifferentLength() public {
    uint64[] memory xFee = new uint64[](3);
    int64[] memory yFee = new int64[](4);

    vm.expectRevert(Errors.InvalidParams.selector);
    hoax(guardian);
    parallelizer.setFees(address(eurA), xFee, yFee, true);
  }

  function test_RevertWhen_InvalidParamsMint() public {
    uint64[] memory xFee = new uint64[](4);
    int64[] memory yFee = new int64[](4);

    xFee[3] = uint64(BASE_9); // xFee[n - 1] >= BASE_9

    vm.expectRevert(Errors.InvalidParams.selector);
    hoax(guardian);
    parallelizer.setFees(address(eurA), xFee, yFee, true);

    xFee[3] = uint64(BASE_9 - 1);
    xFee[0] = uint64(1); // xFee[0] != 0

    vm.expectRevert(Errors.InvalidParams.selector);
    hoax(guardian);
    parallelizer.setFees(address(eurA), xFee, yFee, true);

    xFee[0] = 0;
    yFee[3] = int64(int256(BASE_12 + 1)); // yFee[n - 1] > BASE_12

    vm.expectRevert(Errors.InvalidParams.selector);
    hoax(guardian);
    parallelizer.setFees(address(eurA), xFee, yFee, true);
  }

  function test_RevertWhen_InvalidParamsMintIncreases() public {
    uint64[] memory xFee = new uint64[](3);
    int64[] memory yFee = new int64[](3);

    xFee[0] = 0;
    xFee[1] = uint64((2 * BASE_9) / 10); // Not strictly increasing
    xFee[2] = uint64((2 * BASE_9) / 10);

    yFee[0] = int64(0);
    yFee[1] = int64(uint64(BASE_9 / 10));
    yFee[2] = int64(uint64((2 * BASE_9) / 10));

    vm.expectRevert(Errors.InvalidParams.selector);
    hoax(guardian);
    parallelizer.setFees(address(eurA), xFee, yFee, true);

    xFee[0] = 0;
    xFee[1] = uint64(BASE_9 / 10);
    xFee[2] = uint64((2 * BASE_9) / 10);

    yFee[0] = int64(0);
    yFee[1] = int64(uint64((3 * BASE_9) / 10)); // Not increasing
    yFee[2] = int64(uint64((2 * BASE_9) / 10));

    vm.expectRevert(Errors.InvalidParams.selector);
    hoax(guardian);
    parallelizer.setFees(address(eurA), xFee, yFee, true);
  }

  function test_RevertWhen_OnlyGovernorWithGuardianRoleNegativeFees() public {
    uint64[] memory xFee = new uint64[](3);
    int64[] memory yFee = new int64[](3);

    xFee[2] = 0;
    xFee[1] = uint64(BASE_9 / 10);
    xFee[0] = uint64(BASE_9);

    yFee[0] = int64(1);
    yFee[1] = int64(1);
    yFee[2] = int64(uint64(BASE_9 / 10));

    hoax(governorAndGuardian);
    parallelizer.setFees(address(eurB), xFee, yFee, false);

    xFee[0] = 0;
    xFee[1] = uint64(BASE_9 / 10);
    xFee[2] = uint64((2 * BASE_9) / 10);

    yFee[0] = int64(-1);
    yFee[1] = int64(uint64(BASE_9 / 10));
    yFee[2] = int64(uint64((2 * BASE_9) / 10));

    hoax(governor);
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, governor));
    parallelizer.setFees(address(eurA), xFee, yFee, true);

    hoax(guardian);
    vm.expectRevert(abi.encodeWithSelector(Errors.NotGovernor.selector));
    parallelizer.setFees(address(eurA), xFee, yFee, true);
  }

  function test_RevertWhen_InvalidNegativeFeesMint() public {
    uint64[] memory xFee = new uint64[](3);
    int64[] memory yFee = new int64[](3);

    xFee[2] = 0;
    xFee[1] = uint64(BASE_9 / 10);
    xFee[0] = uint64(BASE_9);

    yFee[0] = int64(1);
    yFee[1] = int64(1);
    yFee[2] = int64(uint64(BASE_9 / 10));

    hoax(governorAndGuardian);
    parallelizer.setFees(address(eurB), xFee, yFee, false);

    xFee[0] = 0;
    xFee[1] = uint64(BASE_9 / 10);
    xFee[2] = uint64((2 * BASE_9) / 10);

    yFee[0] = int64(-2); // Negative Fees lower than the burn fees
    yFee[1] = int64(uint64(BASE_9 / 10));
    yFee[2] = int64(uint64((2 * BASE_9) / 10));

    vm.expectRevert(Errors.InvalidNegativeFees.selector);
    hoax(governorAndGuardian);
    parallelizer.setFees(address(eurA), xFee, yFee, true);
  }

  function test_RevertWhen_InvalidParamsBurn() public {
    uint64[] memory xFee = new uint64[](3);
    int64[] memory yFee = new int64[](3);

    xFee[0] = uint64(0); // xFee[0] != BASE_9
    xFee[1] = uint64(BASE_9 / 10);
    xFee[2] = 0;

    yFee[0] = int64(1);
    yFee[1] = int64(1);
    yFee[2] = int64(uint64(BASE_9 / 10));

    vm.expectRevert(Errors.InvalidParams.selector);
    hoax(governorAndGuardian);
    parallelizer.setFees(address(eurA), xFee, yFee, false);

    xFee[0] = uint64(BASE_9);
    xFee[1] = uint64(BASE_9 / 10);
    xFee[2] = 0;

    yFee[0] = int64(1);
    yFee[1] = int64(1);
    yFee[2] = int64(uint64(BASE_9 + 1)); // yFee[n - 1] > int256(BASE_9)

    vm.expectRevert(Errors.InvalidParams.selector);
    hoax(governorAndGuardian);
    parallelizer.setFees(address(eurA), xFee, yFee, false);

    xFee[0] = uint64(BASE_9);
    xFee[1] = uint64(BASE_9 / 10);
    xFee[2] = 0;

    yFee[0] = int64(1);
    yFee[1] = int64(2); // yFee[1] != yFee[0]
    yFee[2] = int64(uint64(BASE_9 / 10));

    vm.expectRevert(Errors.InvalidParams.selector);
    hoax(governorAndGuardian);
    parallelizer.setFees(address(eurA), xFee, yFee, false);
  }

  function test_RevertWhen_InvalidParamsBurnIncreases() public {
    uint64[] memory xFee = new uint64[](3);
    int64[] memory yFee = new int64[](3);

    xFee[0] = uint64(BASE_9);
    xFee[1] = uint64(BASE_9); // Not strictly decreasing
    xFee[2] = 0;

    yFee[0] = int64(1);
    yFee[1] = int64(1);
    yFee[2] = int64(uint64(BASE_9 / 10));

    vm.expectRevert(Errors.InvalidParams.selector);
    hoax(governorAndGuardian);
    parallelizer.setFees(address(eurA), xFee, yFee, false);

    xFee[0] = uint64(BASE_9);
    xFee[1] = uint64(BASE_9 / 10);
    xFee[2] = 0;

    yFee[0] = int64(2);
    yFee[1] = int64(2);
    yFee[2] = int64(1); // Not increasing

    vm.expectRevert(Errors.InvalidParams.selector);
    hoax(governorAndGuardian);
    parallelizer.setFees(address(eurA), xFee, yFee, false);
  }

  function test_RevertWhen_InvalidNegativeFeesBurn() public {
    uint64[] memory xFee = new uint64[](3);
    int64[] memory yFee = new int64[](3);

    xFee[0] = 0;
    xFee[1] = uint64(BASE_9 / 10);
    xFee[2] = uint64((2 * BASE_9) / 10);

    yFee[0] = int64(1);
    yFee[1] = int64(uint64(BASE_9 / 10));
    yFee[2] = int64(uint64((2 * BASE_9) / 10));

    hoax(governorAndGuardian);
    parallelizer.setFees(address(eurB), xFee, yFee, true);

    xFee[0] = uint64(BASE_9);
    xFee[1] = uint64(BASE_9 / 10);
    xFee[2] = 0;

    yFee[0] = int64(-2);
    yFee[1] = int64(-2);
    yFee[2] = int64(2);

    vm.expectRevert(Errors.InvalidNegativeFees.selector);
    hoax(governorAndGuardian);
    parallelizer.setFees(address(eurA), xFee, yFee, false);
  }

  function test_Mint() public {
    uint64[] memory xFee = new uint64[](3);
    int64[] memory yFee = new int64[](3);

    xFee[0] = 0;
    xFee[1] = uint64(BASE_9 / 10);
    xFee[2] = uint64((2 * BASE_9) / 10);

    yFee[0] = int64(1);
    yFee[1] = int64(uint64(BASE_9 / 10));
    yFee[2] = int64(uint64((2 * BASE_9) / 10));

    vm.expectEmit(address(parallelizer));
    emit LibSetters.FeesSet(address(eurA), xFee, yFee, true);

    hoax(guardian);
    parallelizer.setFees(address(eurA), xFee, yFee, true);

    (uint64[] memory xFeeMint, int64[] memory yFeeMint) = parallelizer.getCollateralMintFees(address(eurA));
    for (uint256 i = 0; i < 3; ++i) {
      assertEq(xFeeMint[i], xFee[i]);
      assertEq(yFeeMint[i], yFee[i]);
    }
  }

  function test_Burn() public {
    uint64[] memory xFee = new uint64[](3);
    int64[] memory yFee = new int64[](3);

    xFee[0] = uint64(BASE_9);
    xFee[1] = uint64(BASE_9 / 10);
    xFee[2] = 0;

    yFee[0] = int64(1);
    yFee[1] = int64(1);
    yFee[2] = int64(uint64(BASE_9 / 10));

    vm.expectEmit(address(parallelizer));
    emit LibSetters.FeesSet(address(eurA), xFee, yFee, false);

    hoax(guardian);
    parallelizer.setFees(address(eurA), xFee, yFee, false);

    (uint64[] memory xFeeBurn, int64[] memory yFeeBurn) = parallelizer.getCollateralBurnFees(address(eurA));
    for (uint256 i = 0; i < 3; ++i) {
      assertEq(xFeeBurn[i], xFee[i]);
      assertEq(yFeeBurn[i], yFee[i]);
    }
  }
}

contract Test_Setters_SetRedemptionCurveParams is Fixture {
  event RedemptionCurveParamsSet(uint64[] xFee, int64[] yFee);

  function test_RevertWhen_NotGuardian() public {
    uint64[] memory xFee = new uint64[](3);
    int64[] memory yFee = new int64[](3);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, governor));
    hoax(governor);
    parallelizer.setRedemptionCurveParams(xFee, yFee);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    hoax(alice);
    parallelizer.setRedemptionCurveParams(xFee, yFee);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, bob));
    hoax(bob);
    parallelizer.setRedemptionCurveParams(xFee, yFee);
  }

  function test_RevertWhen_InvalidParams() public {
    uint64[] memory xFee = new uint64[](3);
    int64[] memory yFee = new int64[](3);

    xFee[0] = uint64(0);
    xFee[1] = uint64(BASE_9 / 10);
    xFee[2] = uint64(BASE_9 + 1);

    yFee[0] = int64(1);
    yFee[1] = int64(2);
    yFee[2] = int64(uint64(BASE_9 / 10));

    vm.expectRevert(Errors.InvalidParams.selector);
    hoax(guardian);
    parallelizer.setRedemptionCurveParams(xFee, yFee);
  }

  function test_RevertWhen_InvalidParamsWhenDecreases() public {
    uint64[] memory xFee = new uint64[](3);
    int64[] memory yFee = new int64[](3);

    xFee[0] = uint64(0);
    xFee[1] = uint64(0); // Not stricly increasing
    xFee[2] = uint64(BASE_9);

    yFee[0] = int64(1);
    yFee[1] = int64(1);
    yFee[2] = int64(uint64(BASE_9 / 10));

    vm.expectRevert(Errors.InvalidParams.selector);
    hoax(guardian);
    parallelizer.setRedemptionCurveParams(xFee, yFee);

    xFee[0] = uint64(0);
    xFee[1] = uint64(1);
    xFee[2] = uint64(BASE_9);

    yFee[0] = int64(2);
    yFee[1] = int64(2);
    yFee[2] = int64(uint64(BASE_9 + 1)); // Not in bounds

    vm.expectRevert(Errors.InvalidParams.selector);
    hoax(guardian);
    parallelizer.setRedemptionCurveParams(xFee, yFee);

    xFee[0] = uint64(0);
    xFee[1] = uint64(1);
    xFee[2] = uint64(BASE_9);

    yFee[0] = int64(2);
    yFee[1] = int64(2);
    yFee[2] = int64(-1); // Not in bounds

    vm.expectRevert(Errors.InvalidParams.selector);
    hoax(guardian);
    parallelizer.setRedemptionCurveParams(xFee, yFee);
  }

  function test_Success() public {
    uint64[] memory xFee = new uint64[](3);
    int64[] memory yFee = new int64[](3);

    xFee[0] = uint64(0);
    xFee[1] = uint64(1);
    xFee[2] = uint64(BASE_9);

    yFee[0] = int64(1);
    yFee[1] = int64(2);
    yFee[2] = int64(3);

    vm.expectEmit(address(parallelizer));
    emit RedemptionCurveParamsSet(xFee, yFee);

    hoax(guardian);
    parallelizer.setRedemptionCurveParams(xFee, yFee);

    (uint64[] memory xRedemptionCurve, int64[] memory yRedemptionCurve) = parallelizer.getRedemptionFees();
    for (uint256 i = 0; i < 3; ++i) {
      assertEq(xRedemptionCurve[i], xFee[i]);
      assertEq(yRedemptionCurve[i], yFee[i]);
    }
  }
}

contract Test_Setters_RecoverERC20 is Fixture {
  event Transfer(address from, address to, uint256 value);

  function test_RevertWhen_NotGovernor() public {
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    hoax(alice);
    parallelizer.recoverERC20(address(tokenP), tokenP, alice, 1 ether);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, guardian));
    hoax(guardian);
    parallelizer.recoverERC20(address(tokenP), tokenP, alice, 1 ether);
  }

  function test_Success() public {
    deal(address(eurA), address(parallelizer), 1 ether);

    hoax(governor);
    parallelizer.recoverERC20(address(eurA), eurA, alice, 1 ether);

    assertEq(eurA.balanceOf(alice), 1 ether);
  }

  function test_SuccessWithManager() public {
    MockManager manager = new MockManager(address(eurA));
    IERC20[] memory subCollaterals = new IERC20[](2);
    subCollaterals[0] = eurA;
    subCollaterals[1] = eurB;
    ManagerStorage memory data =
      ManagerStorage({ subCollaterals: subCollaterals, config: abi.encode(ManagerType.EXTERNAL, abi.encode(manager)) });
    manager.setSubCollaterals(data.subCollaterals, data.config);

    hoax(governor);
    parallelizer.setCollateralManager(address(eurA), data);

    deal(address(eurA), address(manager), 1 ether);

    hoax(governor);
    parallelizer.recoverERC20(address(eurA), eurA, alice, 1 ether);

    assertEq(eurA.balanceOf(alice), 1 ether);

    deal(address(eurB), address(manager), 1 ether);

    hoax(governor);
    parallelizer.recoverERC20(address(eurA), eurB, alice, 1 ether);

    assertEq(eurB.balanceOf(alice), 1 ether);
  }
}

contract Test_Setters_SetAccessManager is Fixture {
  function test_RevertWhen_NonGovernor() public {
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    hoax(alice);
    parallelizer.setAccessManager(alice);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, guardian));
    hoax(guardian);
    parallelizer.setAccessManager(alice);
  }

  function test_Success() public {
    address oldAccessManager = address(parallelizer.accessManager());

    vm.expectEmit(address(parallelizer));
    emit LibSetters.OwnershipTransferred(oldAccessManager, alice);

    hoax(governor);
    parallelizer.setAccessManager(alice);

    assertEq(parallelizer.accessManager(), alice);
  }
}

contract Test_Setters_ToggleTrusted is Fixture {
  event TrustedToggled(address indexed sender, bool isTrusted, TrustedType trustedType);

  function test_RevertWhen_NotGovernor() public {
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, guardian));
    hoax(guardian);
    parallelizer.toggleTrusted(alice, TrustedType.Seller);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    hoax(alice);
    parallelizer.toggleTrusted(alice, TrustedType.Seller);
  }

  function test_Seller() public {
    vm.expectEmit(address(parallelizer));
    emit TrustedToggled(alice, true, TrustedType.Seller);

    hoax(governor);
    parallelizer.toggleTrusted(alice, TrustedType.Seller);

    assert(parallelizer.isTrustedSeller(alice));

    vm.expectEmit(address(parallelizer));
    emit TrustedToggled(alice, false, TrustedType.Seller);

    hoax(governor);
    parallelizer.toggleTrusted(alice, TrustedType.Seller);

    assert(!parallelizer.isTrustedSeller(alice));
  }

  function test_Updater() public {
    vm.expectEmit(address(parallelizer));
    emit TrustedToggled(alice, true, TrustedType.Updater);

    hoax(governor);
    parallelizer.toggleTrusted(alice, TrustedType.Updater);

    assert(parallelizer.isTrusted(alice));

    vm.expectEmit(address(parallelizer));
    emit TrustedToggled(alice, false, TrustedType.Updater);

    hoax(governor);
    parallelizer.toggleTrusted(alice, TrustedType.Updater);

    assert(!parallelizer.isTrusted(alice));
  }
}

contract Test_Setters_SetWhitelistStatus is Fixture {
  function test_RevertWhen_NotGovernor() public {
    bytes memory emptyData;
    bytes memory whitelistData = abi.encode(WhitelistType.BACKED, emptyData);
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, guardian));
    hoax(guardian);
    parallelizer.setWhitelistStatus(address(eurA), 1, whitelistData);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    hoax(alice);
    parallelizer.setWhitelistStatus(address(eurA), 1, whitelistData);
  }

  function test_RevertWhen_NotCollateral() public {
    bytes memory emptyData;
    bytes memory whitelistData = abi.encode(WhitelistType.BACKED, emptyData);
    vm.expectRevert(Errors.NotCollateral.selector);
    hoax(governor);
    parallelizer.setWhitelistStatus(address(this), 1, whitelistData);
  }

  function test_RevertWhen_InvalidWhitelistData() public {
    bytes memory whitelistData = abi.encode(3, 4);
    vm.expectRevert();
    hoax(governor);
    parallelizer.setWhitelistStatus(address(this), 1, whitelistData);
  }

  function test_SetPositiveStatus() public {
    bytes memory emptyData;
    bytes memory whitelistData = abi.encode(WhitelistType.BACKED, emptyData);
    assert(!parallelizer.isWhitelistedCollateral(address(eurA)));
    assertEq(parallelizer.getCollateralWhitelistData(address(eurA)), emptyData);

    vm.expectEmit(address(parallelizer));
    emit LibSetters.CollateralWhitelistStatusUpdated(address(eurA), whitelistData, 1);

    hoax(governor);
    parallelizer.setWhitelistStatus(address(eurA), 1, whitelistData);

    assert(parallelizer.isWhitelistedCollateral(address(eurA)));
    assertEq(parallelizer.getCollateralWhitelistData(address(eurA)), whitelistData);
  }

  function test_SetPositiveStatusThroughNonEmptyData() public {
    MockKeyringGuard keyringGuard = new MockKeyringGuard();

    bytes memory whitelistData = abi.encode(WhitelistType.BACKED, abi.encode(address(0)));
    assert(!parallelizer.isWhitelistedCollateral(address(eurA)));
    bytes memory emptyData;
    assertEq(parallelizer.getCollateralWhitelistData(address(eurA)), emptyData);

    vm.expectEmit(address(parallelizer));
    emit LibSetters.CollateralWhitelistStatusUpdated(address(eurA), whitelistData, 1);

    hoax(governor);
    parallelizer.setWhitelistStatus(address(eurA), 1, whitelistData);

    assert(parallelizer.isWhitelistedCollateral(address(eurA)));
    assertEq(parallelizer.getCollateralWhitelistData(address(eurA)), whitelistData);

    assert(!parallelizer.isWhitelistedForCollateral(address(eurA), address(bob)));
    whitelistData = abi.encode(WhitelistType.BACKED, abi.encode(address(keyringGuard)));
    hoax(governor);
    parallelizer.setWhitelistStatus(address(eurA), 1, whitelistData);
    assertEq(parallelizer.getCollateralWhitelistData(address(eurA)), whitelistData);
    assert(parallelizer.isWhitelistedCollateral(address(eurA)));
    keyringGuard.setAuthorized(address(bob), true);
    assert(parallelizer.isWhitelistedForCollateral(address(eurA), address(bob)));
    keyringGuard.setAuthorized(address(bob), false);
    assert(!parallelizer.isWhitelistedForCollateral(address(eurA), address(bob)));
  }

  function test_SetNegativeStatus() public {
    bytes memory emptyData;
    bytes memory whitelistData = abi.encode(WhitelistType.BACKED, emptyData);
    assert(!parallelizer.isWhitelistedCollateral(address(eurA)));
    assertEq(parallelizer.getCollateralWhitelistData(address(eurA)), emptyData);

    vm.expectEmit(address(parallelizer));
    emit LibSetters.CollateralWhitelistStatusUpdated(address(eurA), whitelistData, 1);

    hoax(governor);
    parallelizer.setWhitelistStatus(address(eurA), 1, whitelistData);

    assert(parallelizer.isWhitelistedCollateral(address(eurA)));
    assertEq(parallelizer.getCollateralWhitelistData(address(eurA)), whitelistData);

    bytes memory whitelistData2 = abi.encode(WhitelistType.BACKED, emptyData);
    vm.expectEmit(address(parallelizer));
    emit LibSetters.CollateralWhitelistStatusUpdated(address(eurA), whitelistData2, 0);

    hoax(governor);
    parallelizer.setWhitelistStatus(address(eurA), 0, whitelistData2);

    assert(!parallelizer.isWhitelistedCollateral(address(eurA)));
    assertEq(parallelizer.getCollateralWhitelistData(address(eurA)), whitelistData);
  }
}

contract Test_Setters_ToggleWhitelist is Fixture {
  event WhitelistStatusToggled(WhitelistType whitelistType, address indexed who, uint256 whitelistStatus);

  function test_RevertWhen_NonGuardian() public {
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    hoax(alice);
    parallelizer.toggleWhitelist(WhitelistType.BACKED, address(alice));
  }

  function test_WhitelistSet() public {
    vm.expectEmit(address(parallelizer));
    emit WhitelistStatusToggled(WhitelistType.BACKED, address(alice), 1);
    hoax(guardian);
    parallelizer.toggleWhitelist(WhitelistType.BACKED, address(alice));

    assert(parallelizer.isWhitelistedForType(WhitelistType.BACKED, address(alice)));
  }

  function test_WhitelistUnset() public {
    vm.expectEmit(address(parallelizer));
    emit WhitelistStatusToggled(WhitelistType.BACKED, address(alice), 1);
    hoax(guardian);
    parallelizer.toggleWhitelist(WhitelistType.BACKED, address(alice));

    assert(parallelizer.isWhitelistedForType(WhitelistType.BACKED, address(alice)));

    vm.expectEmit(address(parallelizer));
    emit WhitelistStatusToggled(WhitelistType.BACKED, address(alice), 0);
    hoax(guardian);
    parallelizer.toggleWhitelist(WhitelistType.BACKED, address(alice));

    assert(!parallelizer.isWhitelistedForType(WhitelistType.BACKED, address(alice)));
  }

  function test_WhitelistSetOnCollateral() public {
    assert(parallelizer.isWhitelistedForCollateral(address(eurA), address(alice)));
    vm.expectEmit(address(parallelizer));
    emit WhitelistStatusToggled(WhitelistType.BACKED, address(alice), 1);
    hoax(guardian);
    parallelizer.toggleWhitelist(WhitelistType.BACKED, address(alice));

    assert(parallelizer.isWhitelistedForType(WhitelistType.BACKED, address(alice)));
    assert(parallelizer.isWhitelistedForCollateral(address(eurA), address(alice)));

    bytes memory emptyData;
    bytes memory whitelistData = abi.encode(WhitelistType.BACKED, emptyData);
    hoax(governor);
    parallelizer.setWhitelistStatus(address(eurA), 1, whitelistData);

    assert(parallelizer.isWhitelistedForCollateral(address(eurA), address(alice)));

    hoax(guardian);
    parallelizer.toggleWhitelist(WhitelistType.BACKED, address(alice));
    assert(!parallelizer.isWhitelistedForCollateral(address(eurA), address(alice)));
  }
}

contract Test_Setters_UpdateNormalizer is Fixture {
  event NormalizerUpdated(uint256 newNormalizerValue);

  function test_RevertWhen_NotTrusted() public {
    vm.expectRevert(Errors.NotTrusted.selector);
    parallelizer.updateNormalizer(1 ether, true);

    vm.expectRevert(Errors.NotTrusted.selector);
    hoax(alice);
    parallelizer.updateNormalizer(1 ether, true);

    vm.expectRevert(Errors.NotTrusted.selector);
    hoax(guardian);
    parallelizer.updateNormalizer(1 ether, true);
  }

  function test_RevertWhen_ZeroAmountNormalizedStables() public {
    vm.expectRevert(); // Should be a division by 0
    hoax(governor);
    parallelizer.updateNormalizer(1, true);
  }

  function test_RevertWhen_InvalidUpdate() public {
    _mintExactOutput(alice, address(eurA), 1 ether, 1 ether);
    _mintExactOutput(alice, address(eurB), 1 ether, 1 ether);

    vm.expectRevert(stdError.arithmeticError); // Should be an underflow
    hoax(governor);
    parallelizer.updateNormalizer(4 ether, false);
  }

  function test_UpdateByGovernor() public {
    _mintExactOutput(alice, address(eurA), 1 ether, 1 ether);

    vm.expectEmit(address(parallelizer));
    emit NormalizerUpdated(2 * BASE_27);

    hoax(governor);
    parallelizer.updateNormalizer(1 ether, true);

    (uint256 stablecoinsFromCollateral, uint256 stablecoinsIssued) = parallelizer.getIssuedByCollateral(address(eurA));
    assertEq(stablecoinsFromCollateral, 2 ether);
    assertEq(stablecoinsIssued, 2 ether);

    uint256 normalizer =
      uint256(vm.load(address(parallelizer), bytes32(uint256(TRANSMUTER_STORAGE_POSITION) + 1))) >> 128;
    uint256 normalizedStables =
      (uint256(vm.load(address(parallelizer), bytes32(uint256(TRANSMUTER_STORAGE_POSITION) + 1))) << 128) >> 128;
    assertEq(normalizer, 2 * BASE_27);
    assertEq(normalizedStables, 1 ether);
  }

  function test_UpdateByWhitelisted() public {
    _mintExactOutput(alice, address(eurA), 1 ether, 1 ether);
    _mintExactOutput(alice, address(eurB), 1 ether, 1 ether);

    hoax(governor);
    parallelizer.toggleTrusted(alice, TrustedType.Updater);

    vm.expectEmit(address(parallelizer));
    emit NormalizerUpdated(2 * BASE_27);

    hoax(alice);
    // Increase of 2 with 2 in the system -> x2
    parallelizer.updateNormalizer(2 ether, true);

    (uint256 stablecoinsFromCollateral, uint256 stablecoinsIssued) = parallelizer.getIssuedByCollateral(address(eurA));
    assertEq(stablecoinsFromCollateral, 2 ether);
    assertEq(stablecoinsIssued, 4 ether);
    (stablecoinsFromCollateral, stablecoinsIssued) = parallelizer.getIssuedByCollateral(address(eurB));
    assertEq(stablecoinsFromCollateral, 2 ether);
    assertEq(stablecoinsIssued, 4 ether);

    uint256 normalizer =
      uint256(vm.load(address(parallelizer), bytes32(uint256(TRANSMUTER_STORAGE_POSITION) + 1))) >> 128;
    uint256 normalizedStables =
      (uint256(vm.load(address(parallelizer), bytes32(uint256(TRANSMUTER_STORAGE_POSITION) + 1))) << 128) >> 128;
    assertEq(normalizer, 2 * BASE_27); // 2x increase via the function call
    assertEq(normalizedStables, 2 ether);
  }

  function test_Decrease() public {
    _mintExactOutput(alice, address(eurA), 1 ether, 1 ether);
    _mintExactOutput(alice, address(eurB), 1 ether, 1 ether);

    vm.expectEmit(address(parallelizer));
    emit NormalizerUpdated(BASE_27 / 2);

    hoax(governor);
    // Decrease of 1 with 2 in the system -> /2
    parallelizer.updateNormalizer(1 ether, false);

    (uint256 stablecoinsFromCollateral, uint256 stablecoinsIssued) = parallelizer.getIssuedByCollateral(address(eurA));
    assertEq(stablecoinsFromCollateral, 1 ether / 2);
    assertEq(stablecoinsIssued, 1 ether);
    (stablecoinsFromCollateral, stablecoinsIssued) = parallelizer.getIssuedByCollateral(address(eurB));
    assertEq(stablecoinsFromCollateral, 1 ether / 2);
    assertEq(stablecoinsIssued, 1 ether);

    uint256 normalizer =
      uint256(vm.load(address(parallelizer), bytes32(uint256(TRANSMUTER_STORAGE_POSITION) + 1))) >> 128;
    uint256 normalizedStables =
      (uint256(vm.load(address(parallelizer), bytes32(uint256(TRANSMUTER_STORAGE_POSITION) + 1))) << 128) >> 128;
    assertEq(normalizer, BASE_27 / 2);
    assertEq(normalizedStables, 2 ether);
  }

  function test_LargeIncrease() public {
    _mintExactOutput(alice, address(eurA), 1 ether, 1 ether);
    _mintExactOutput(alice, address(eurB), 1 ether, 1 ether);
    // normalizer -> 1e27, normalizedStables -> 2e18

    hoax(governor);
    parallelizer.updateNormalizer(2 * (BASE_27 - 1 ether), true);
    // normalizer should do 1e27 -> 1e27 + 1e36 - 1e27 = 1e36

    (uint256 stablecoinsFromCollateral, uint256 stablecoinsIssued) = parallelizer.getIssuedByCollateral(address(eurA));
    assertEq(stablecoinsFromCollateral, BASE_27); // 1e27 stable backed by eurA
    assertEq(stablecoinsIssued, 2 * BASE_27);
    (stablecoinsFromCollateral, stablecoinsIssued) = parallelizer.getIssuedByCollateral(address(eurB));
    assertEq(stablecoinsFromCollateral, BASE_27); // 1e27 stable backed by eurB
    assertEq(stablecoinsIssued, 2 * BASE_27);

    uint256 normalizer =
      uint256(vm.load(address(parallelizer), bytes32(uint256(TRANSMUTER_STORAGE_POSITION) + 1))) >> 128;
    uint256 normalizedStables =
      (uint256(vm.load(address(parallelizer), bytes32(uint256(TRANSMUTER_STORAGE_POSITION) + 1))) << 128) >> 128;
    assertEq(normalizer, BASE_27); // RENORMALIZED
    assertEq(normalizedStables, 2 * BASE_27);
  }
}

contract Test_Setters_SetCollateralManager is Fixture {
  event CollateralManagerSet(address indexed collateral, ManagerStorage managerData);

  function test_RevertWhen_NotGovernor() public {
    ManagerStorage memory data = ManagerStorage(new IERC20[](0), abi.encode(ManagerType.EXTERNAL, address(0)));

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, guardian));
    hoax(guardian);
    parallelizer.setCollateralManager(address(eurA), data);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    hoax(alice);
    parallelizer.setCollateralManager(address(eurA), data);
  }

  function test_RevertWhen_NotCollateral() public {
    ManagerStorage memory data = ManagerStorage(new IERC20[](0), abi.encode(ManagerType.EXTERNAL, address(0)));

    vm.expectRevert(Errors.NotCollateral.selector);
    hoax(governor);
    parallelizer.setCollateralManager(address(this), data);
  }

  function test_RevertWhen_InvalidParams() public {
    MockManager manager = new MockManager(address(eurA)); // Deploy a mock manager for eurA
    IERC20[] memory subCollaterals = new IERC20[](1);
    subCollaterals[0] = eurB;
    ManagerStorage memory data =
      ManagerStorage({ subCollaterals: subCollaterals, config: abi.encode(ManagerType.EXTERNAL, abi.encode(manager)) });

    vm.expectRevert(Errors.InvalidParams.selector);
    hoax(governor);
    parallelizer.setCollateralManager(address(eurA), data);
  }

  function test_AddManager() public {
    MockManager manager = new MockManager(address(eurA)); // Deploy a mock manager for eurA
    IERC20[] memory subCollaterals = new IERC20[](1);
    subCollaterals[0] = eurA;
    ManagerStorage memory data = ManagerStorage({
      subCollaterals: subCollaterals,
      config: abi.encode(ManagerType.EXTERNAL, abi.encode(address(manager)))
    });

    (bool isManaged, IERC20[] memory fetchedSubCollaterals, bytes memory config) =
      parallelizer.getManagerData(address(eurA));
    assertEq(isManaged, false);
    assertEq(fetchedSubCollaterals.length, 0);
    assertEq(config.length, 0);

    vm.expectEmit(address(parallelizer));
    emit CollateralManagerSet(address(eurA), data);

    hoax(governor);
    parallelizer.setCollateralManager(address(eurA), data);

    // Refetch storage to check the update
    (isManaged, fetchedSubCollaterals, config) = parallelizer.getManagerData(address(eurA));
    (, bytes memory aux) = abi.decode(config, (ManagerType, bytes));
    address fetched = abi.decode(aux, (address));

    assertEq(isManaged, true);
    assertEq(fetchedSubCollaterals.length, 1);
    assertEq(address(fetchedSubCollaterals[0]), address(eurA));
    assertEq(fetched, address(manager));
  }

  function test_RemoveManager() public {
    MockManager manager = new MockManager(address(eurA)); // Deploy a mock manager for eurA
    IERC20[] memory subCollaterals = new IERC20[](1);
    subCollaterals[0] = eurA;
    ManagerStorage memory data =
      ManagerStorage({ subCollaterals: subCollaterals, config: abi.encode(ManagerType.EXTERNAL, abi.encode(manager)) });

    hoax(governor);
    parallelizer.setCollateralManager(address(eurA), data);

    data = ManagerStorage({ subCollaterals: new IERC20[](0), config: "" });
    hoax(governor);
    parallelizer.setCollateralManager(address(eurA), data);

    (bool isManaged, IERC20[] memory fetchedSubCollaterals, bytes memory config) =
      parallelizer.getManagerData(address(eurA));
    assertEq(isManaged, false);
    assertEq(fetchedSubCollaterals.length, 0);
    assertEq(config.length, 0);
  }
}

contract Test_Setters_ChangeAllowance is Fixture {
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function test_RevertWhen_NotGovernor() public {
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, guardian));
    hoax(guardian);
    parallelizer.changeAllowance(eurA, alice, 1 ether);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    hoax(alice);
    parallelizer.changeAllowance(eurA, alice, 1 ether);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, guardian));
    hoax(guardian);
    parallelizer.changeAllowance(eurA, alice, 1 ether);
  }

  function test_SafeIncreaseFrom0() public {
    vm.expectEmit(address(eurA));

    emit Approval(address(parallelizer), alice, 1 ether);

    hoax(governor);
    parallelizer.changeAllowance(eurA, alice, 1 ether);

    assertEq(eurA.allowance(address(parallelizer), alice), 1 ether);
  }

  function test_SafeIncreaseFromNon0() public {
    hoax(governor);
    parallelizer.changeAllowance(eurA, alice, 1 ether);

    vm.expectEmit(address(eurA));
    emit Approval(address(parallelizer), alice, 2 ether);

    hoax(governor);
    parallelizer.changeAllowance(eurA, alice, 2 ether);

    assertEq(eurA.allowance(address(parallelizer), alice), 2 ether);
  }

  function test_SafeDecrease() public {
    hoax(governor);
    parallelizer.changeAllowance(eurA, alice, 1 ether);

    vm.expectEmit(address(eurA));
    emit Approval(address(parallelizer), alice, 0);

    hoax(governor);
    parallelizer.changeAllowance(eurA, alice, 0);

    assertEq(eurA.allowance(address(parallelizer), alice), 0);
  }
}

contract Test_Setters_AddCollateral is Fixture {
  event CollateralAdded(address indexed collateral);

  function test_RevertWhen_NotGovernor() public {
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, guardian));
    hoax(guardian);
    parallelizer.addCollateral(address(eurA));

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    hoax(alice);
    parallelizer.addCollateral(address(eurA));

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, guardian));
    hoax(guardian);
    parallelizer.addCollateral(address(eurA));
  }

  function test_RevertWhen_AlreadyAdded() public {
    vm.expectRevert(Errors.AlreadyAdded.selector);
    hoax(governor);
    parallelizer.addCollateral(address(eurA));
  }

  function test_Success() public {
    uint256 length = parallelizer.getCollateralList().length;

    vm.expectEmit(address(parallelizer));
    emit CollateralAdded(address(tokenP));

    hoax(governor);
    parallelizer.addCollateral(address(tokenP));

    address[] memory list = parallelizer.getCollateralList();
    assertEq(list.length, length + 1);
    assertEq(address(tokenP), list[list.length - 1]);
    assertEq(parallelizer.getCollateralDecimals(address(tokenP)), tokenP.decimals());
  }
}

contract Test_Setters_AdjustNormalizedStablecoins is Fixture {
  event ReservesAdjusted(address indexed collateral, uint256 amount, bool increase);

  function test_RevertWhen_NotGovernor() public {
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, guardian));
    hoax(guardian);
    parallelizer.adjustStablecoins(address(eurA), 1 ether, true);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    hoax(alice);
    parallelizer.adjustStablecoins(address(eurA), 1 ether, true);
  }

  function test_RevertWhen_NotCollateral() public {
    vm.expectRevert(Errors.NotCollateral.selector);
    hoax(governor);
    parallelizer.adjustStablecoins(address(this), 1 ether, true);
  }

  function test_Decrease() public {
    _mintExactOutput(alice, address(eurA), 1 ether, 1 ether);
    _mintExactOutput(alice, address(eurB), 1 ether, 1 ether);

    vm.expectEmit(address(parallelizer));
    emit ReservesAdjusted(address(eurA), 1 ether / 2, false);

    hoax(governor);
    parallelizer.adjustStablecoins(address(eurA), 1 ether / 2, false);

    (uint256 stablecoinsFromCollateral, uint256 stablecoinsIssued) = parallelizer.getIssuedByCollateral(address(eurA));
    assertEq(stablecoinsFromCollateral, 1 ether / 2);
    assertEq(stablecoinsIssued, 3 ether / 2);

    uint256 normalizer =
      uint256(vm.load(address(parallelizer), bytes32(uint256(TRANSMUTER_STORAGE_POSITION) + 1))) >> 128;
    uint256 normalizedStables =
      (uint256(vm.load(address(parallelizer), bytes32(uint256(TRANSMUTER_STORAGE_POSITION) + 1))) << 128) >> 128;
    assertEq(normalizer, BASE_27);
    assertEq(normalizedStables, 3 ether / 2);
  }

  function test_Increase() public {
    _mintExactOutput(alice, address(eurA), 1 ether, 1 ether);
    _mintExactOutput(alice, address(eurB), 1 ether, 1 ether);

    vm.expectEmit(address(parallelizer));
    emit ReservesAdjusted(address(eurA), 1 ether / 2, true);

    hoax(governor);
    parallelizer.adjustStablecoins(address(eurA), 1 ether / 2, true);

    (uint256 stablecoinsFromCollateral, uint256 stablecoinsIssued) = parallelizer.getIssuedByCollateral(address(eurA));
    assertEq(stablecoinsFromCollateral, 3 ether / 2);
    assertEq(stablecoinsIssued, 5 ether / 2);

    uint256 normalizer =
      uint256(vm.load(address(parallelizer), bytes32(uint256(TRANSMUTER_STORAGE_POSITION) + 1))) >> 128;
    uint256 normalizedStables =
      (uint256(vm.load(address(parallelizer), bytes32(uint256(TRANSMUTER_STORAGE_POSITION) + 1))) << 128) >> 128;
    assertEq(normalizer, BASE_27);
    assertEq(normalizedStables, 5 ether / 2);
  }
}

contract Test_Setters_RevokeCollateral is Fixture {
  event CollateralRevoked(address indexed collateral);

  function test_RevertWhen_NotGovernor() public {
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    hoax(alice);
    parallelizer.adjustStablecoins(address(eurA), 1 ether, true);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, guardian));
    hoax(guardian);
    parallelizer.adjustStablecoins(address(eurA), 1 ether, true);
  }

  function test_RevertWhen_NotCollateral() public {
    vm.expectRevert(Errors.NotCollateral.selector);
    hoax(governor);
    parallelizer.adjustStablecoins(address(this), 1 ether, true);
  }

  function test_RevertWhen_StillBacked() public {
    _mintExactOutput(alice, address(eurA), 1 ether, 1 ether);

    vm.expectRevert(Errors.NotCollateral.selector);
    hoax(governor);
    parallelizer.adjustStablecoins(address(this), 1 ether, true);
  }

  function test_RevertWhen_ManagerHasAssets() public {
    MockManager manager = new MockManager(address(eurA));
    IERC20[] memory subCollaterals = new IERC20[](2);
    subCollaterals[0] = eurA;
    subCollaterals[1] = eurB;
    ManagerStorage memory data =
      ManagerStorage({ subCollaterals: subCollaterals, config: abi.encode(ManagerType.EXTERNAL, abi.encode(manager)) });
    manager.setSubCollaterals(data.subCollaterals, "");

    hoax(governor);
    parallelizer.setCollateralManager(address(eurA), data);

    deal(address(eurA), address(manager), 1 ether);

    vm.expectRevert(Errors.ManagerHasAssets.selector);

    hoax(governor);
    parallelizer.revokeCollateral(address(eurA));
  }

  function test_Success() public {
    address[] memory prevlist = parallelizer.getCollateralList();

    vm.expectEmit(address(parallelizer));
    emit CollateralRevoked(address(eurA));

    hoax(governor);
    parallelizer.revokeCollateral(address(eurA));

    address[] memory list = parallelizer.getCollateralList();
    assertEq(list.length, prevlist.length - 1);

    for (uint256 i = 0; i < list.length; i++) {
      assertNotEq(address(list[i]), address(eurA));
    }

    assertEq(0, parallelizer.getCollateralDecimals(address(eurA)));

    (uint64[] memory xFeeMint, int64[] memory yFeeMint) = parallelizer.getCollateralMintFees(address(eurA));
    assertEq(0, xFeeMint.length);
    assertEq(0, yFeeMint.length);

    (uint64[] memory xFeeBurn, int64[] memory yFeeBurn) = parallelizer.getCollateralMintFees(address(eurA));
    assertEq(0, xFeeBurn.length);
    assertEq(0, yFeeBurn.length);

    vm.expectRevert(Errors.NotCollateral.selector);
    parallelizer.isPaused(address(eurA), ActionType.Mint);
    vm.expectRevert(Errors.NotCollateral.selector);
    parallelizer.isPaused(address(eurA), ActionType.Burn);
    vm.expectRevert();
    parallelizer.getOracle(address(eurA));
    vm.expectRevert();
    parallelizer.getOracleValues(address(eurA));
    (bool managed,,) = parallelizer.getManagerData(address(eurA));
    assert(!managed);
    (uint256 issued,) = parallelizer.getIssuedByCollateral(address(eurA));
    assertEq(0, issued);
    assert(parallelizer.isWhitelistedForCollateral(address(eurA), address(this)));
  }

  function test_SuccessWithManager() public {
    MockManager manager = new MockManager(address(eurA));
    IERC20[] memory subCollaterals = new IERC20[](2);
    subCollaterals[0] = eurA;
    subCollaterals[1] = eurB;
    ManagerStorage memory data =
      ManagerStorage({ subCollaterals: subCollaterals, config: abi.encode(ManagerType.EXTERNAL, abi.encode(manager)) });
    manager.setSubCollaterals(data.subCollaterals, "");

    hoax(governor);
    parallelizer.setCollateralManager(address(eurA), data);

    address[] memory prevlist = parallelizer.getCollateralList();

    vm.expectEmit(address(parallelizer));
    emit CollateralRevoked(address(eurA));

    hoax(governor);
    parallelizer.revokeCollateral(address(eurA));

    address[] memory list = parallelizer.getCollateralList();
    assertEq(list.length, prevlist.length - 1);

    for (uint256 i = 0; i < list.length; i++) {
      assertNotEq(address(list[i]), address(eurA));
    }

    assertEq(0, parallelizer.getCollateralDecimals(address(eurA)));
    assertEq(0, eurA.balanceOf(address(manager)));
    assertEq(0, eurA.balanceOf(address(parallelizer)));

    (bool managed,,) = parallelizer.getManagerData(address(eurA));
    assert(!managed);
  }
}

contract Test_Setters_DiamondEtherscan is Fixture {
  event Upgraded(address indexed implementation);

  function test_RevertWhen_NotGuardian() public {
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, governor));
    hoax(governor);
    parallelizer.setDummyImplementation(address(bob));

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    hoax(alice);
    parallelizer.setDummyImplementation(address(bob));

    hoax(guardian);
    vm.expectEmit(address(parallelizer));
    emit Upgraded(address(bob));
    parallelizer.setDummyImplementation(address(bob));
    assertEq(parallelizer.implementation(), address(bob));
  }
}

contract Test_Setters_SetStablecoinCap is Fixture {
  event StablecoinCapSet(address indexed collateral, uint256 stablecoinCap);

  function test_RevertWhen_NotGuardian() public {
    hoax(governor);
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, governor));
    parallelizer.setStablecoinCap(address(eurA), 1 ether);
    hoax(governor);
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, governor));
    parallelizer.setStablecoinCap(address(eurB), 1 ether);
    hoax(governor);
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, governor));
    parallelizer.setStablecoinCap(address(eurY), 1 ether);

    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    hoax(alice);
    parallelizer.setStablecoinCap(address(eurA), 1 ether);
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    hoax(alice);
    parallelizer.setStablecoinCap(address(eurB), 1 ether);
    vm.expectRevert(abi.encodeWithSelector(Errors.AccessManagedUnauthorized.selector, alice));
    hoax(alice);
    parallelizer.setStablecoinCap(address(eurY), 1 ether);
  }

  function test_RevertWhen_NotCollateral() public {
    vm.expectRevert(Errors.NotCollateral.selector);
    hoax(guardian);
    parallelizer.setStablecoinCap(address(tokenP), 1 ether);

    vm.expectRevert(Errors.NotCollateral.selector);
    hoax(guardian);
    parallelizer.setStablecoinCap(address(this), 1 ether);
  }

  function test_SetStablecoinCap_Success() public {
    hoax(guardian);
    parallelizer.setStablecoinCap(address(eurA), 1 ether);
    hoax(guardian);
    parallelizer.setStablecoinCap(address(eurB), 1 ether);
    hoax(guardian);
    parallelizer.setStablecoinCap(address(eurY), 1 ether);

    assertEq(parallelizer.getStablecoinCap(address(eurA)), 1 ether);
    assertEq(parallelizer.getStablecoinCap(address(eurB)), 1 ether);
    assertEq(parallelizer.getStablecoinCap(address(eurY)), 1 ether);
  }
}
