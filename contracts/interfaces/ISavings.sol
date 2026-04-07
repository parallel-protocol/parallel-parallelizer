// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import { IEIP3009 } from "./external/IEIP3009.sol";

/// @title ISavings
/// @author Cooper Labs
/// @custom:contact security@cooperlabs.xyz
interface ISavings is IEIP3009 {
  function depositWithAuthorization(
    uint256 assets,
    address receiver,
    address owner,
    uint256 validAfter,
    uint256 validBefore,
    bytes32 nonce,
    uint8 v,
    bytes32 r,
    bytes32 s
  )
    external
    returns (uint256 shares);

  function redeemWithAuthorization(
    uint256 shares,
    address receiver,
    address owner,
    uint256 validAfter,
    uint256 validBefore,
    bytes32 nonce,
    uint8 v,
    bytes32 r,
    bytes32 s
  )
    external
    returns (uint256 assets);

  function cancelAuthorization(address authorizer, bytes32 nonce, uint8 v, bytes32 r, bytes32 s) external;

  function authorizationState(address authorizer, bytes32 nonce) external view returns (bool);

  // solhint-disable-next-line func-name-mixedcase
  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function estimatedAPR() external view returns (uint256 apr);

  function computeUpdatedAssets(uint256 totalAssets, uint256 exp) external view returns (uint256);

  function togglePause() external;

  function toggleTrusted(address trustedAddress) external;

  function setRate(uint208 newRate) external;

  function setMaxRate(uint256 newMaxRate) external;

  function initializeEIP3009(string memory name_) external;
}
