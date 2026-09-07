// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.28;

import { IERC3156FlashBorrower } from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { MockTokenPermit } from "./MockTokenPermit.sol";

/// @dev Zero-fee ERC-3156 lender: mints the principal to the borrower and pulls it back through the
/// allowance the borrower granted, mirroring FlashParallelToken closely enough for the rebalancer.
contract MockFlashLoan {
  bytes32 internal constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

  function maxFlashLoan(address) external pure returns (uint256) {
    return type(uint256).max;
  }

  function flashFee(address, uint256) external pure returns (uint256) {
    return 0;
  }

  function flashLoan(
    IERC3156FlashBorrower receiver,
    address token,
    uint256 amount,
    bytes calldata data
  )
    external
    returns (bool)
  {
    MockTokenPermit(token).mint(address(receiver), amount);
    require(receiver.onFlashLoan(msg.sender, token, amount, 0, data) == CALLBACK_SUCCESS, "bad callback");
    IERC20(token).transferFrom(address(receiver), address(this), amount);
    MockTokenPermit(token).burn(address(this), amount);
    return true;
  }
}
