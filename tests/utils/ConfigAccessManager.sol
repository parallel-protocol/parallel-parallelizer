// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import { AccessManager, IAccessManaged } from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

import { Savings } from "contracts/savings/Savings.sol";
import { SavingsNameable } from "contracts/savings/nameable/SavingsNameable.sol";
import { BaseSavings } from "contracts/savings/BaseSavings.sol";
import { BaseHarvester } from "contracts/helpers/BaseHarvester.sol";
import { MultiBlockHarvester } from "contracts/helpers/MultiBlockHarvester.sol";
import { GenericHarvester } from "contracts/helpers/GenericHarvester.sol";
import { SettersGuardian } from "contracts/parallelizer/facets/SettersGuardian.sol";
import { SettersGovernor } from "contracts/parallelizer/facets/SettersGovernor.sol";
import { DiamondEtherscan } from "contracts/parallelizer/facets/DiamondEtherscan.sol";
import "contracts/utils/Constants.sol";
import "./Helper.sol";

import "@forge-std/console.sol";

abstract contract ConfigAccessManager is Helper {
  AccessManager public accessManager;

  function deployAccessManager(
    address _initialAdmin,
    address _governor,
    address _guardian,
    address _governorAndGuardian
  )
    internal
  {
    accessManager = new AccessManager(_initialAdmin);
    vm.label({ account: address(accessManager), newLabel: "AccessManager" });
    // Set the roles
    vm.startPrank(_initialAdmin);
    accessManager.grantRole(GOVERNOR_ROLE, _governor, 0);
    accessManager.grantRole(GUARDIAN_ROLE, _guardian, 0);
    accessManager.grantRole(GOVERNOR_ROLE, _governorAndGuardian, 0);
    accessManager.grantRole(GUARDIAN_ROLE, _governorAndGuardian, 0);
    vm.stopPrank();
  }

  function getGuardianSavingsSelectorAccess() internal pure returns (bytes4[] memory) {
    bytes4[] memory selectors = new bytes4[](3);
    selectors[0] = Savings.togglePause.selector;
    selectors[1] = Savings.toggleTrusted.selector;
    selectors[2] = Savings.setRate.selector;
    return selectors;
  }

  function getGovernorSavingsSelectorAccess() internal pure returns (bytes4[] memory) {
    bytes4[] memory selectors = new bytes4[](3);
    selectors[0] = SavingsNameable.setNameAndSymbol.selector;
    selectors[1] = Savings.setMaxRate.selector;
    selectors[2] = UUPSUpgradeable.upgradeToAndCall.selector;
    return selectors;
  }

  function getGuardianBaseHarvesterSelectorAccess() internal pure returns (bytes4[] memory) {
    bytes4[] memory selectors = new bytes4[](5);
    selectors[0] = BaseHarvester.setYieldBearingAssetData.selector;
    selectors[1] = BaseHarvester.setMaxSlippage.selector;
    selectors[2] = BaseHarvester.toggleTrusted.selector;
    selectors[3] = BaseHarvester.recoverERC20.selector;
    selectors[4] = BaseHarvester.setTargetExposure.selector;
    return selectors;
  }

  function getGovernorMultiBlockHarvesterSelectorAccess() internal pure returns (bytes4[] memory) {
    bytes4[] memory selectors = new bytes4[](1);
    selectors[0] = MultiBlockHarvester.setYieldBearingToDepositAddress.selector;
    return selectors;
  }

  function getGovernorGenericHarvesterSelectorAccess() internal pure returns (bytes4[] memory) {
    bytes4[] memory selectors = new bytes4[](2);
    selectors[0] = GenericHarvester.setTokenTransferAddress.selector;
    selectors[1] = GenericHarvester.setSwapRouter.selector;
    return selectors;
  }

  function getParallelizerGuardianSelectorAccess() internal pure returns (bytes4[] memory) {
    bytes4[] memory selectors = new bytes4[](6);
    selectors[0] = SettersGuardian.togglePause.selector;
    selectors[1] = SettersGuardian.setFees.selector;
    selectors[2] = SettersGuardian.setRedemptionCurveParams.selector;
    selectors[3] = SettersGuardian.toggleWhitelist.selector;
    selectors[4] = SettersGuardian.setStablecoinCap.selector;
    selectors[5] = DiamondEtherscan.setDummyImplementation.selector;
    return selectors;
  }

  function getParallelizerGovernorSelectorAccess() internal pure returns (bytes4[] memory) {
    bytes4[] memory selectors = new bytes4[](11);
    selectors[0] = SettersGovernor.recoverERC20.selector;
    selectors[1] = SettersGovernor.setAccessManager.selector;
    selectors[2] = SettersGovernor.setCollateralManager.selector;
    selectors[3] = SettersGovernor.changeAllowance.selector;
    selectors[4] = SettersGovernor.toggleTrusted.selector;
    selectors[5] = SettersGovernor.addCollateral.selector;
    selectors[6] = SettersGovernor.adjustStablecoins.selector;
    selectors[7] = SettersGovernor.revokeCollateral.selector;
    selectors[8] = SettersGovernor.setOracle.selector;
    selectors[9] = SettersGovernor.updateOracle.selector;
    selectors[10] = SettersGovernor.setWhitelistStatus.selector;
    return selectors;
  }
}
