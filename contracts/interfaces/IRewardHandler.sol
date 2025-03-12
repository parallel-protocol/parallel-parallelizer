// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

/// @title IRewardHandler
/// @author Cooper Labs
/// @custom:contact security@cooperlabs.xyz
/// @dev This interface is a friendly fork of Angle's `IRewardHandler` interface
/// https://github.com/AngleProtocol/angle-transmuter/blob/main/contracts/interfaces/IRewardHandler.sol
interface IRewardHandler {
  /// @notice Sells some external tokens through a 1inch call
  /// @param minAmountOut Minimum amount of the outToken to get
  /// @param payload Payload to pass to 1inch
  /// @return amountOut Amount obtained of the outToken
  function sellRewards(uint256 minAmountOut, bytes memory payload) external returns (uint256 amountOut);
}
