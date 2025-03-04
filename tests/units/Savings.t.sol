// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import { IERC20Metadata } from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { IAccessManaged } from "contracts/utils/AccessManagedUpgradeable.sol";
import { Savings } from "contracts/savings/Savings.sol";
import { SavingsNameable } from "contracts/savings/nameable/SavingsNameable.sol";

import "../Fixture.sol";

contract SavingsNameableUpgradeTest is Fixture {
  string public name = "Staked EURp";
  string public symbol = "sEURp";

  SavingsNameable public saving;

  function setUp() public override {
    super.setUp();
    vm.startPrank(governor);
    deal({ token: address(agToken), to: governor, give: 1e18 });

    SavingsNameable savingsImpl = new SavingsNameable();

    // Calculate the future proxy address
    address futureProxyAddress = vm.computeCreateAddress(governor, vm.getNonce(governor));

    // Pre-approve the future proxy address
    agToken.approve(futureProxyAddress, 1e18);

    saving = SavingsNameable(
      address(
        new ERC1967Proxy(
          address(savingsImpl),
          abi.encodeWithSelector(
            savingsImpl.initialize.selector, accessManager, IERC20Metadata(address(agToken)), name, symbol, 1
          )
        )
      )
    );
    vm.label(address(saving), "saving");

    // grant access to required functions for governor role
    accessManager.setTargetFunctionRole(futureProxyAddress, getGovernorSavingsSelectorAccess(), GOVERNOR_ROLE);
  }

  function test_deploySavings() public {
    assertEq(IERC20Metadata(saving).name(), name);
    assertEq(IERC20Metadata(saving).symbol(), symbol);
    assertEq(SavingsNameable(saving).previewRedeem(Constants.BASE_18), Constants.BASE_18);
    assertEq(SavingsNameable(saving).previewWithdraw(Constants.BASE_18), Constants.BASE_18);
    assertEq(SavingsNameable(saving).previewMint(Constants.BASE_18), Constants.BASE_18);
    assertEq(SavingsNameable(saving).previewDeposit(Constants.BASE_18), Constants.BASE_18);
    assertEq(SavingsNameable(saving).totalAssets(), Constants.BASE_18);
    assertEq(SavingsNameable(saving).totalSupply(), Constants.BASE_18);
    assertEq(SavingsNameable(saving).maxRate(), 0);
    assertEq(SavingsNameable(saving).paused(), 0);
    assertEq(SavingsNameable(saving).lastUpdate(), 0);
    assertEq(SavingsNameable(saving).rate(), 0);
  }

  function test_upgradeSavings() public {
    string memory newName = "new Staked EURp";
    string memory newSymbol = "new sEURp";

    address newSavingsImpl = address(new SavingsNameable());
    saving.upgradeToAndCall(newSavingsImpl, "");

    vm.startPrank(governor);
    SavingsNameable(saving).setNameAndSymbol(newName, newSymbol);

    assertEq(IERC20Metadata(saving).name(), newName);
    assertEq(IERC20Metadata(saving).symbol(), newSymbol);
    assertEq(SavingsNameable(saving).previewRedeem(Constants.BASE_18), Constants.BASE_18);
    assertEq(SavingsNameable(saving).previewWithdraw(Constants.BASE_18), Constants.BASE_18);
    assertEq(SavingsNameable(saving).previewMint(Constants.BASE_18), Constants.BASE_18);
    assertEq(SavingsNameable(saving).previewDeposit(Constants.BASE_18), Constants.BASE_18);
    assertEq(SavingsNameable(saving).totalAssets(), Constants.BASE_18);
    assertEq(SavingsNameable(saving).totalSupply(), Constants.BASE_18);
    assertEq(SavingsNameable(saving).maxRate(), 0);
    assertEq(SavingsNameable(saving).paused(), 0);
    assertEq(SavingsNameable(saving).lastUpdate(), 0);
    assertEq(SavingsNameable(saving).rate(), 0);
  }

  function test_upgradeSavings_RevertWhen_CallerIsNotGovernor() public {
    vm.startPrank(alice);
    address newSavingsImpl = address(new SavingsNameable());
    vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, alice));
    saving.upgradeToAndCall(newSavingsImpl, "");
  }
}
