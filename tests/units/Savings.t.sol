// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import { IERC20Metadata } from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";

import { IAccessManaged } from "contracts/utils/AccessManagedUpgradeable.sol";

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
