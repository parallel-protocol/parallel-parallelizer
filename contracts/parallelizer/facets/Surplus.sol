// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

import { ISurplus } from "contracts/interfaces/ISurplus.sol";
import { ISwapper } from "contracts/interfaces/ISwapper.sol";
import { IGetters } from "contracts/interfaces/IGetters.sol";
import { ITokenP } from "contracts/interfaces/ITokenP.sol";

import { LibOracle } from "../libraries/LibOracle.sol";
import { LibHelpers } from "../libraries/LibHelpers.sol";
import { LibStorage as s } from "../libraries/LibStorage.sol";
import { AccessManagedModifiers } from "./AccessManagedModifiers.sol";

import "../../utils/Constants.sol";
import "../../utils/Errors.sol";
import "../Storage.sol";

import { console2 } from "@forge-std/console2.sol";

/// @title Surplus
/// @author Cooper Labs
/// @custom:contact security@cooperlabs.xyz
contract Surplus is AccessManagedModifiers, ISurplus {
  using SafeERC20 for IERC20;
  using Math for uint256;

  event SurplusProcessed(uint256 collateralSurplus, uint256 stableSurplus, uint256 issuedAmount);
  event IncomeReleased(uint256 income, uint256 releasedAt);
  event IncomeReleasedToPayee(uint256 income, address payee, uint256 releasedAt);

  /// @inheritdoc ISurplus
  function processSurplus(address collateral)
    external
    returns (uint256 collateralSurplus, uint256 stableSurplus, uint256 issuedAmount)
  {
    ParallelizerStorage storage ts = s.transmuterStorage();
    (collateralSurplus, stableSurplus) = _computeCollateralSurplus(collateral);
    if (collateralSurplus == 0) revert ZeroAmount();
    uint256 minExpectedAmount = _minExpectedAmount(stableSurplus, ts.slippageTolerance[collateral]);
    IERC20(collateral).approve(address(this), collateralSurplus);
    issuedAmount = ISwapper(address(this)).swapExactInput(
      collateralSurplus, minExpectedAmount, collateral, address(ts.tokenP), address(this), block.timestamp
    );
    emit SurplusProcessed(collateralSurplus, stableSurplus, issuedAmount);
  }

  /// @inheritdoc ISurplus
  function getCollateralSurplus(address collateral)
    external
    view
    returns (uint256 collateralSurplus, uint256 stableSurplus)
  {
    return _computeCollateralSurplus(collateral);
  }

  /// @notice Releases the income to the payees
  /// @return payees The addresses of the payees
  /// @return amounts The amounts released to the payees
  function release() external nonReentrant returns (address[] memory payees, uint256[] memory) {
    ParallelizerStorage storage ts = s.transmuterStorage();
    uint256 income = ts.tokenP.balanceOf(address(this));
    if (income == 0) revert ZeroAmount();
    payees = ts.payees;
    if (payees.length == 0) revert InvalidLengths();
    ts.lastReleasedAt = block.timestamp;
    // Mint USDX to all receivers
    uint256 i;
    uint256[] memory amounts = new uint256[](payees.length);
    for (; i < payees.length; ++i) {
      address payee = payees[i];
      amounts[i] = _release(income, payee, ts);
    }

    emit IncomeReleased(income, ts.lastReleasedAt);
    return (payees, amounts);
  }

  /// @notice Computes the surplus of a collateral.
  /// @param collateral The collateral address to compute the surplus of.
  /// @return collateralSurplus The collateral surplus amount.
  /// @return stableSurplus The surplus in stable amount.
  function _computeCollateralSurplus(address collateral)
    internal
    view
    returns (uint256 collateralSurplus, uint256 stableSurplus)
  {
    uint256 currentCollateralBalance = IERC20(collateral).balanceOf(address(this));
    ParallelizerStorage storage ts = s.transmuterStorage();
    Collateral storage collatInfo = ts.collaterals[collateral];
    uint256 oracleValue = LibOracle.readMint(collatInfo.oracleConfig);
    uint256 totalCollateralValue =
      LibHelpers.convertDecimalTo(oracleValue * currentCollateralBalance, 18 + collatInfo.decimals, 18);
    stableSurplus = totalCollateralValue - collatInfo.normalizedStables;
    collateralSurplus = LibHelpers.convertDecimalTo((stableSurplus * BASE_18) / oracleValue, 18, collatInfo.decimals);
  }

  /// @notice Computes the minimum expected amount of stablecoins to receive for a given surplus.
  /// @param stableSurplus The surplus in stable amount.
  /// @param slippageTolerance The slippage tolerance.
  /// @return minExpectedAmount The minimum expected amount of stablecoins to receive.
  function _minExpectedAmount(
    uint256 stableSurplus,
    uint256 slippageTolerance
  )
    internal
    pure
    returns (uint256 minExpectedAmount)
  {
    return (stableSurplus * (BASE_9 - slippageTolerance)) / BASE_9;
  }

  /// @notice Internal function to release a percentage of income to a specific payee.
  /// @dev uses totalShares to calculate correct share.
  /// @param _totalIncomeReceived Total income for all payees, will be split according to shares.
  /// @param _payee The address of the payee to whom to distribute the fees.
  /// @param _ts The contract storage.
  /// @return income The amount transfer to the payee.
  function _release(
    uint256 _totalIncomeReceived,
    address _payee,
    ParallelizerStorage storage _ts
  )
    internal
    returns (uint256 income)
  {
    income = _totalIncomeReceived.mulDiv(_ts.shares[_payee], _ts.totalShares);
    if (_payee == address(0)) {
      _ts.tokenP.burnSelf(income, address(this));
    } else {
      IERC20(address(_ts.tokenP)).safeTransfer(_payee, income);
    }
    emit IncomeReleasedToPayee(income, _payee, _ts.lastReleasedAt);
  }
}
