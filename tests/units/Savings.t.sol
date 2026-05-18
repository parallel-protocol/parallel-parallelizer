// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import { IERC20Metadata } from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";

import { IAccessManaged } from "contracts/utils/AccessManagedUpgradeable.sol";

import { SavingsNameable } from "contracts/savings/nameable/SavingsNameable.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "../Fixture.sol";

contract SavingsNameableUpgradeTest is Fixture {
  function setUp() public override {
    super.setUp();

    saving = SavingsNameable(deploySavings(governor, address(tokenP), address(accessManager)));
    vm.label(address(saving), "saving");

    // grant access to required functions for governor role
    vm.startPrank(governor);
    accessManager.setTargetFunctionRole(address(saving), getGovernorSavingsSelectorAccess(), GOVERNOR_ROLE);
    vm.stopPrank();
  }

  function test_deploySavings() public {
    assertEq(IERC20Metadata(saving).name(), name);
    assertEq(IERC20Metadata(saving).symbol(), symbol);
    assertEq(saving.previewRedeem(Constants.BASE_18), Constants.BASE_18);
    assertEq(saving.previewWithdraw(Constants.BASE_18), Constants.BASE_18);
    assertEq(saving.previewMint(Constants.BASE_18), Constants.BASE_18);
    assertEq(saving.previewDeposit(Constants.BASE_18), Constants.BASE_18);
    assertEq(saving.totalAssets(), Constants.BASE_18);
    assertEq(saving.totalSupply(), Constants.BASE_18);
    assertEq(saving.maxRate(), 0);
    assertEq(saving.paused(), 0);
    assertEq(saving.lastUpdate(), 0);
    assertEq(saving.rate(), 0);
  }

  function test_upgradeSavings() public {
    string memory newName = "new Staked USDp";
    string memory newSymbol = "new sUSDp";
    vm.startPrank(governor);

    address newSavingsImpl = address(new SavingsNameable());
    saving.upgradeToAndCall(newSavingsImpl, "");

    saving.setNameAndSymbol(newName, newSymbol);

    assertEq(IERC20Metadata(saving).name(), newName);
    assertEq(IERC20Metadata(saving).symbol(), newSymbol);
    assertEq(saving.previewRedeem(Constants.BASE_18), Constants.BASE_18);
    assertEq(saving.previewWithdraw(Constants.BASE_18), Constants.BASE_18);
    assertEq(saving.previewMint(Constants.BASE_18), Constants.BASE_18);
    assertEq(saving.previewDeposit(Constants.BASE_18), Constants.BASE_18);
    assertEq(saving.totalAssets(), Constants.BASE_18);
    assertEq(saving.totalSupply(), Constants.BASE_18);
    assertEq(saving.maxRate(), 0);
    assertEq(saving.paused(), 0);
    assertEq(saving.lastUpdate(), 0);
    assertEq(saving.rate(), 0);
  }

  function test_upgradeSavings_RevertWhen_CallerIsNotGovernor() public {
    vm.startPrank(alice);
    address newSavingsImpl = address(new SavingsNameable());
    vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, alice));
    saving.upgradeToAndCall(newSavingsImpl, "");
  }
}

contract SavingsInitializeValidationTest is Fixture {
  SavingsNameable internal savingsImpl;

  function setUp() public override {
    super.setUp();
    savingsImpl = new SavingsNameable();
    deal({ token: address(tokenP), to: governor, give: 1e18 });
  }

  function _initData(string memory n, string memory s, uint256 divizer) internal view returns (bytes memory) {
    return abi.encodeWithSelector(
      savingsImpl.initialize.selector, address(accessManager), IERC20Metadata(address(tokenP)), n, s, divizer
    );
  }

  function test_initialize_RevertWhen_DivizerIsZero() public {
    vm.prank(governor);
    vm.expectRevert(InvalidParam.selector);
    new ERC1967Proxy(address(savingsImpl), _initData(name, symbol, 0));
  }

  function test_initialize_RevertWhen_DivizerExceedsBase18() public {
    vm.prank(governor);
    vm.expectRevert(InvalidParam.selector);
    new ERC1967Proxy(address(savingsImpl), _initData(name, symbol, Constants.BASE_18 + 1));
  }

  function test_initialize_RevertWhen_DivizerExceedsAssetDecimalsScale() public {
    uint256 divizer = 10 ** uint256(IERC20Metadata(address(tokenP)).decimals()) + 1;
    vm.prank(governor);
    vm.expectRevert(InvalidParam.selector);
    new ERC1967Proxy(address(savingsImpl), _initData(name, symbol, divizer));
  }

  function test_initialize_RevertWhen_NameIsEmpty() public {
    vm.prank(governor);
    vm.expectRevert(InvalidParam.selector);
    new ERC1967Proxy(address(savingsImpl), _initData("", symbol, 1));
  }

  function test_initialize_RevertWhen_SymbolIsEmpty() public {
    vm.prank(governor);
    vm.expectRevert(InvalidParam.selector);
    new ERC1967Proxy(address(savingsImpl), _initData(name, "", 1));
  }

  function test_initialize_SucceedsWithValidDivizer() public {
    vm.startPrank(governor);
    address futureProxy = vm.computeCreateAddress(governor, vm.getNonce(governor));
    IERC20(address(tokenP)).approve(futureProxy, 1e18);
    address proxy = address(new ERC1967Proxy(address(savingsImpl), _initData(name, symbol, 1)));
    vm.stopPrank();
    SavingsNameable s = SavingsNameable(proxy);
    assertGt(s.totalSupply(), 0, "dead-share moat must be planted");
    assertGt(s.totalAssets(), 0, "seed assets must be deposited");
    assertEq(IERC20Metadata(s).name(), name);
    assertEq(IERC20Metadata(s).symbol(), symbol);
  }
}

contract SavingsMaxViewsPauseTest is Fixture {
  function setUp() public override {
    super.setUp();
    saving = SavingsNameable(deploySavings(governor, address(tokenP), address(accessManager)));
    vm.label(address(saving), "saving");

    vm.startPrank(governor);
    accessManager.setTargetFunctionRole(address(saving), getGuardianSavingsSelectorAccess(), GUARDIAN_ROLE);
    vm.stopPrank();
  }

  function _pause() internal {
    vm.prank(guardian);
    saving.togglePause();
    assertEq(saving.paused(), 1, "savings must be paused");
  }

  function test_maxViews_returnZeroWhenPaused() public {
    assertEq(saving.maxDeposit(alice), type(uint256).max);
    assertEq(saving.maxMint(alice), type(uint256).max);

    _pause();

    assertEq(saving.maxDeposit(alice), 0, "maxDeposit must be 0 when paused");
    assertEq(saving.maxMint(alice), 0, "maxMint must be 0 when paused");
    assertEq(saving.maxWithdraw(alice), 0, "maxWithdraw must be 0 when paused");
    assertEq(saving.maxRedeem(alice), 0, "maxRedeem must be 0 when paused");
  }

  function test_maxViews_restoredAfterUnpause() public {
    _pause();

    vm.prank(guardian);
    saving.togglePause();
    assertEq(saving.paused(), 0, "savings must be unpaused");

    assertEq(saving.maxDeposit(alice), type(uint256).max);
    assertEq(saving.maxMint(alice), type(uint256).max);
  }

  function test_maxWithdraw_reflectsOwnerBalanceWhenPaused() public {
    deal({ token: address(tokenP), to: alice, give: Constants.BASE_18 });
    vm.startPrank(alice);
    IERC20(address(tokenP)).approve(address(saving), Constants.BASE_18);
    uint256 shares = saving.deposit(Constants.BASE_18, alice);
    vm.stopPrank();
    assertGt(shares, 0);

    uint256 withdrawableBefore = saving.maxWithdraw(alice);
    uint256 redeemableBefore = saving.maxRedeem(alice);
    assertGt(withdrawableBefore, 0);
    assertEq(redeemableBefore, shares);

    _pause();

    assertEq(saving.maxWithdraw(alice), 0, "maxWithdraw must be 0 when paused even with balance");
    assertEq(saving.maxRedeem(alice), 0, "maxRedeem must be 0 when paused even with balance");
  }
}
