// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;


import { SavingsNameable } from "contracts/savings/nameable/SavingsNameable.sol";
import { Savings } from "contracts/savings/Savings.sol";
import { Vm } from "@forge-std/Vm.sol";

import { IERC20Metadata } from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import { ITransparentUpgradeableProxy,TransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import "../Fixture.sol";

contract SavingsNameableUpgradeTest is Fixture {
    string public name = "Staked EURp";
    string public symbol = "sEURp";

    address public saving;
    address public savingsImpl;
    
    function setUp() public override{
        super.setUp();
        vm.startPrank(governor);
        
        deal({token: address(agToken), to: governor, give:1e18});

        savingsImpl = address(new SavingsNameable());
        vm.recordLogs();
        saving = address(
            new TransparentUpgradeableProxy(savingsImpl, governor,"")
        );

        Vm.Log[] memory entries = vm.getRecordedLogs();
        proxyAdmin= ProxyAdmin(entries[1].emitter);
    
        vm.label(saving, "saving");
        agToken.approve(saving, 1e18);

        SavingsNameable(saving).initialize(
            accessControlManager,
            IERC20Metadata(address(agToken)),
            name,
            symbol,
            1
        );
        
    }

    function test_deploySavings() public {
        assertEq(IERC20Metadata(saving).name(), name);
        assertEq(IERC20Metadata(saving).symbol(), symbol);
        assertEq(SavingsNameable(saving).previewRedeem(Constants.BASE_18),Constants.BASE_18);
        assertEq(SavingsNameable(saving).previewWithdraw(Constants.BASE_18),Constants.BASE_18);
        assertEq(SavingsNameable(saving).previewMint(Constants.BASE_18),Constants.BASE_18);
        assertEq(SavingsNameable(saving).previewDeposit(Constants.BASE_18),Constants.BASE_18);
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

        savingsImpl = address(new SavingsNameable());
        proxyAdmin.upgradeAndCall(ITransparentUpgradeableProxy(saving), savingsImpl, "");
        SavingsNameable(saving).setNameAndSymbol(newName, newSymbol);

        assertEq(IERC20Metadata(saving).name(), newName);
        assertEq(IERC20Metadata(saving).symbol(), newSymbol);
        assertEq(SavingsNameable(saving).previewRedeem(Constants.BASE_18),Constants.BASE_18);
        assertEq(SavingsNameable(saving).previewWithdraw(Constants.BASE_18),Constants.BASE_18);
        assertEq(SavingsNameable(saving).previewMint(Constants.BASE_18),Constants.BASE_18);
        assertEq(SavingsNameable(saving).previewDeposit(Constants.BASE_18),Constants.BASE_18);
        assertEq(SavingsNameable(saving).totalAssets(), Constants.BASE_18);
        assertEq(SavingsNameable(saving).totalSupply(), Constants.BASE_18);
        assertEq(SavingsNameable(saving).maxRate(), 0);
        assertEq(SavingsNameable(saving).paused(), 0);
        assertEq(SavingsNameable(saving).lastUpdate(), 0);
        assertEq(SavingsNameable(saving).rate(), 0);
    }

}
