// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

/// @title ISurplus
/// @author Cooper Labs
/// @custom:contact security@cooperlabs.xyz
interface ISurplus {
  /// @dev This function will swap the surplus of a collateral for the stable asset link to the protocol.
  /// @param collateral The collateral address to process the surplus of.
  /// @return collateralSurplus The surplus of the collateral.
  /// @return stableSurplus The surplus amount in stable calculated from the collateral surplus.
  /// @return issuedAmount The amount of newly issued stablecoins from the collateral swapped
  function processSurplus(address collateral)
    external
    returns (uint256 collateralSurplus, uint256 stableSurplus, uint256 issuedAmount);

  /// @notice Releases the income to the payees
  /// @return payees The addresses of the payees
  /// @return amounts The amounts released to the payees
  function release() external returns (address[] memory payees, uint256[] memory amounts);
}
