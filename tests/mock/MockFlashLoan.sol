// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC3156FlashLender } from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import { IERC3156FlashBorrower } from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

/// @notice Mock flash loan contract for testing
contract MockFlashLoan is IERC3156FlashLender {
  IERC20 public immutable token;

  constructor(address _token) {
    token = IERC20(_token);
  }

  function maxFlashLoan(address _token) external view returns (uint256) {
    if (_token == address(token)) return type(uint256).max;
    return 0;
  }

  function flashFee(address _token, uint256) external pure returns (uint256) {
    require(_token != address(0), "Invalid token");
    return 0;
  }

  function flashLoan(
    IERC3156FlashBorrower receiver,
    address _token,
    uint256 amount,
    bytes calldata data
  )
    external
    returns (bool)
  {
    require(_token == address(token), "Unsupported token");

    token.transfer(address(receiver), amount);

    require(
      receiver.onFlashLoan(msg.sender, _token, amount, 0, data) == keccak256("ERC3156FlashBorrower.onFlashLoan"),
      "Callback failed"
    );

    token.transferFrom(address(receiver), address(this), amount);

    return true;
  }
}
