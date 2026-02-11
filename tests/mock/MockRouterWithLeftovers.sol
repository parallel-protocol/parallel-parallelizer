// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @notice Mock router that simulates partial token consumption for testing
/// @dev This mock extends the functionality of MockOdosRouter by allowing configurable
///      consumption rates. Unlike MockOdosRouter which consumes exactly `amountIn`,
///      this mock can consume a percentage (e.g., 70%, 99.9%) to simulate malicious
///      routers that don't fully consume approved tokens. When rate is 100%, it consumes
///      ALL available tokens from the caller, matching real router behavior.
contract MockRouterWithLeftovers {
  using SafeERC20 for IERC20;

  uint256 public consumptionRate;

  constructor(uint256 _rate) {
    consumptionRate = _rate;
  }

  function swap(uint256 amountIn, address tokenIn, uint256 amountOut, address tokenOut) external {
    uint256 toConsume;
    if (consumptionRate == 10_000) {
      // If 100%, consume everything available (matching real router behavior)
      toConsume = IERC20(tokenIn).balanceOf(msg.sender);
    } else {
      // Otherwise consume only the percentage
      toConsume = (amountIn * consumptionRate) / 10_000;
    }

    IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), toConsume);
    IERC20(tokenOut).safeTransfer(msg.sender, amountOut);
  }
}
