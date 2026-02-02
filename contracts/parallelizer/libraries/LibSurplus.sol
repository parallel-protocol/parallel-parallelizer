// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

import { LibManager } from "../libraries/LibManager.sol";
import { LibOracle } from "../libraries/LibOracle.sol";
import { LibHelpers } from "../libraries/LibHelpers.sol";
import { LibStorage as s } from "../libraries/LibStorage.sol";

import "../../utils/Constants.sol";
import "../../utils/Errors.sol";
import "../Storage.sol";

/// @title LibSurplus
/// @author Cooper Labs
/// @custom:contact security@cooperlabs.xyz
library LibSurplus {
  using SafeERC20 for IERC20;
  using Math for uint256;

  event IncomeReleased(uint256 income, uint256 releasedAt);
  event IncomeReleasedToPayee(uint256 income, address payee, uint256 releasedAt);

  /// @notice Internal version of `release`
  function release(
    uint256 _incomeToRelease,
    address[] memory _payees
  )
    internal
    returns (address[] memory payees, uint256[] memory amounts)
  {
    ParallelizerStorage storage ts = s.transmuterStorage();
    ts.lastReleasedAt = block.timestamp;
    uint256 i;
    amounts = new uint256[](_payees.length);
    for (; i < _payees.length; ++i) {
      address payee = _payees[i];
      amounts[i] = _release(_incomeToRelease, payee, ts);
    }

    emit IncomeReleased(_incomeToRelease, ts.lastReleasedAt);
    return (_payees, amounts);
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

  /// @notice Computes the surplus of a collateral.
  /// @param collateral The collateral address to compute the surplus of.
  /// @return collateralSurplus The collateral surplus amount.
  /// @return stableSurplus The surplus in stable amount.
  function _computeCollateralSurplus(address collateral)
    internal
    view
    returns (uint256 collateralSurplus, uint256 stableSurplus)
  {
    ParallelizerStorage storage ts = s.transmuterStorage();
    Collateral storage collatInfo = ts.collaterals[collateral];
    uint256 currentCollateralBalance;
    if (collatInfo.isManaged > 0) {
      (, currentCollateralBalance) = LibManager.totalAssets(collatInfo.managerData.config);
    } else {
      currentCollateralBalance = IERC20(collateral).balanceOf(address(this));
    }
    uint256 oracleValue = LibOracle.readMint(collatInfo.oracleConfig);
    uint256 totalCollateralValue =
      LibHelpers.convertDecimalTo(oracleValue * currentCollateralBalance, 18 + collatInfo.decimals, 18);
    uint256 stablesBacked = (uint256(collatInfo.normalizedStables) * ts.normalizer) / BASE_27;
    stableSurplus = totalCollateralValue - stablesBacked;
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
}
