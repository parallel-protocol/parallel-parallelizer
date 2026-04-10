// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { EIP3009 } from "./EIP3009.sol";

/// @title SavingsEIP3009
/// @author Cooper Labs
/// @custom:contact security@cooperlabs.xyz
/// @notice Extends the standard EIP-3009 implementation with Savings-specific signed-intent
/// typehashes for authorized deposits and redemptions.
/// @dev The standard EIP-3009 typehashes (`TransferWithAuthorization`, `ReceiveWithAuthorization`)
/// only commit to `(from, to, value, validAfter, validBefore, nonce)`. A Savings deposit or redeem
/// flow also depends on a `receiver` parameter (where minted shares or redeemed underlying are
/// sent), which is NOT covered by those standard typehashes. If the signed authorization does not
/// bind `receiver`, a relayer can front-run a meta-transaction and redirect the proceeds to an
/// attacker-controlled address.
///
/// The typehashes below additionally bind a `vault` field containing the target Savings contract
/// address. While the EIP-712 domain separator already includes `verifyingContract = address(this)`
/// (making cross-vault signature replay cryptographically impossible), the explicit `vault` field
/// surfaces the target contract directly in the signed struct so that wallets displaying the typed
/// data show users exactly which vault they are authorizing. The on-chain verification also
/// cross-checks `vault == address(this)` as belt-and-suspenders.
///
/// `EIP3009.sol` is left untouched as a clean, standards-only base.
abstract contract SavingsEIP3009 is EIP3009 {
  // keccak256("DepositWithAuthorization(address vault,address owner,address receiver,uint256 assets,
  //   uint256 validAfter,uint256 validBefore,bytes32 nonce)")
  bytes32 public constant DEPOSIT_WITH_AUTHORIZATION_TYPEHASH = keccak256(
    "DepositWithAuthorization(address vault,address owner,address receiver,uint256 assets,uint256 validAfter,uint256 validBefore,bytes32 nonce)"
  );

  // keccak256("RedeemWithAuthorization(address vault,address owner,address receiver,uint256 shares,
  //   uint256 validAfter,uint256 validBefore,bytes32 nonce)")
  bytes32 public constant REDEEM_WITH_AUTHORIZATION_TYPEHASH = keccak256(
    "RedeemWithAuthorization(address vault,address owner,address receiver,uint256 shares,uint256 validAfter,uint256 validBefore,bytes32 nonce)"
  );

  error InvalidVault();

  /// @notice Verifies and consumes a deposit authorization signed over the
  /// `DEPOSIT_WITH_AUTHORIZATION_TYPEHASH` against this contract's EIP-712 domain.
  /// @dev Reuses EIP-3009's `authorizationStates` mapping for nonce tracking, so a given
  /// `(owner, nonce)` tuple can only be used once across any authorization type on this contract.
  /// The `vault` field must equal `address(this)`; this is redundant with the domain separator's
  /// `verifyingContract` binding but makes the target explicit in the signed struct.
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

  /// @notice Verifies and consumes a redeem authorization signed over the
  /// `REDEEM_WITH_AUTHORIZATION_TYPEHASH` against this contract's EIP-712 domain.
  /// @dev The `vault` field must equal `address(this)`.
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
