// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { EIP3009 } from "./EIP3009.sol";

/// @title SavingsEIP3009
/// @author Cooper Labs
/// @custom:contact security@cooperlabs.xyz
/// @notice Adds Savings-specific signed-intent typehashes (deposit/redeem) on top of the standard
/// EIP-3009 base, so the signed authorization also binds the `receiver` parameter and can't be
/// replayed by a relayer with a different destination.
/// @dev The `vault` field is redundant with the domain separator's `verifyingContract` but is
/// included so wallets displaying the typed data surface the target contract explicitly.
abstract contract SavingsEIP3009 is EIP3009 {
  bytes32 public constant DEPOSIT_WITH_AUTHORIZATION_TYPEHASH = keccak256(
    "DepositWithAuthorization(address vault,address owner,address receiver,uint256 assets,uint256 validAfter,uint256 validBefore,bytes32 nonce)"
  );

  bytes32 public constant REDEEM_WITH_AUTHORIZATION_TYPEHASH = keccak256(
    "RedeemWithAuthorization(address vault,address owner,address receiver,uint256 shares,uint256 validAfter,uint256 validBefore,bytes32 nonce)"
  );

  error InvalidVault();

  /// @notice Verifies and consumes a deposit authorization.
  /// @dev Reuses EIP-3009's `authorizationStates` mapping, so an `(owner, nonce)` tuple can only
  /// be used once across any authorization type on this contract.
  function _consumeDepositAuthorization(
    address vault,
    address owner,
    address receiver,
    uint256 assets,
    uint256 validAfter,
    uint256 validBefore,
    bytes32 nonce,
    bytes memory signature
  )
    internal
  {
    if (vault != address(this)) revert InvalidVault();
    _requireValidAuthorization(owner, nonce, validAfter, validBefore);
    _requireValidSignature(
      owner,
      keccak256(
        abi.encode(
          DEPOSIT_WITH_AUTHORIZATION_TYPEHASH, vault, owner, receiver, assets, validAfter, validBefore, nonce
        )
      ),
      signature
    );
    _markAuthorizationAsUsed(owner, nonce);
  }

  /// @notice Verifies and consumes a redeem authorization.
  function _consumeRedeemAuthorization(
    address vault,
    address owner,
    address receiver,
    uint256 shares,
    uint256 validAfter,
    uint256 validBefore,
    bytes32 nonce,
    bytes memory signature
  )
    internal
  {
    if (vault != address(this)) revert InvalidVault();
    _requireValidAuthorization(owner, nonce, validAfter, validBefore);
    _requireValidSignature(
      owner,
      keccak256(
        abi.encode(
          REDEEM_WITH_AUTHORIZATION_TYPEHASH, vault, owner, receiver, shares, validAfter, validBefore, nonce
        )
      ),
      signature
    );
    _markAuthorizationAsUsed(owner, nonce);
  }
}
