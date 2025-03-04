// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.28;

import "../utils/Constants.sol";
import { DiamondStorage, TransmuterStorage, Collateral, FacetInfo, WhitelistType } from "./Storage.sol";

/// @notice Contract mimicking the overall storage layout of the transmuter system.
/// @dev Not meant to be deployed or used. The goals are:
///  - To ensure the storage layout is well understood by everyone
///  - To force test failures if the layout is changed
/// @dev
///  - uint256(TRANSMUTER_STORAGE_POSITION)
///         = 87725637715361972314474735372533017845526400132006062725239677556399819577533
///  - uint256(DIAMOND_STORAGE_POSITION)
///         = 90909012999857140622417080374671856515688564136957639390032885430481714942747
///  - uint256(IMPLEMENTATION_STORAGE_POSITION)
///         = 24440054405305269366569402256811496959409073762505157381672968839269610695612
contract Layout {
  // uint256(IMPLEMENTATION_STORAGE_POSITION)
  uint256[24_440_054_405_305_269_366_569_402_256_811_496_959_409_073_762_505_157_381_672_968_839_269_610_695_612]
    private __gap1;
  address public implementation;
  // uint256(TRANSMUTER_STORAGE_POSITION) - 1 - uint256(IMPLEMENTATION_STORAGE_POSITION)
  uint256[63_285_583_310_056_702_947_905_333_115_721_520_886_117_326_369_500_905_343_566_708_717_130_208_881_920]
    private __gap2;
  address public agToken; // slot 1
  uint8 public isRedemptionLive; // slot 1
  uint8 public nonReentrant; // slot 1
  bool public consumingSchedule; // slot 1
  uint128 public normalizedStables; // slot 2
  uint128 public normalizer; // slot 2
  address[] public collateralList; // slot 3
  uint64[] public xRedemptionCurve; // slot 4
  int64[] public yRedemptionCurve; // slot 5
  mapping(address => Collateral) public collaterals; // slot 6
  mapping(address => uint256) public isTrusted; // slot 7
  mapping(address => uint256) public isSellerTrusted; // slot 8
  mapping(WhitelistType => mapping(address => uint256)) public isWhitelistedForType; // slot 9
  // uint256(TRANSMUTER_STORAGE_POSITION) - TransmuterStorage offset (9) - uint256(DIAMOND_STORAGE_POSITION)
  uint256[3_183_375_284_495_168_307_942_345_002_138_838_670_162_164_004_951_576_664_793_207_874_081_895_365_205]
    private __gap3;
  bytes4[] public selectors; // slot 1
  mapping(bytes4 => FacetInfo) public selectorInfo; // slot 2
  address public accessManager; // slot 3
}
