// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import "contracts/interfaces/external/chainlink/AggregatorV3Interface.sol";

import "../libraries/LibOracle.sol";
import { LibSetters } from "../libraries/LibSetters.sol";
import { LibStorage as s } from "../libraries/LibStorage.sol";

import "../../utils/Constants.sol";
import "../Storage.sol" as Storage;

struct CollateralSetup {
  address token;
  bytes oracleConfig;
  uint64[] xMintFee;
  int64[] yMintFee;
  uint64[] xBurnFee;
  int64[] yBurnFee;
}

struct RedemptionSetup {
  uint64[] xRedeemFee;
  int64[] yRedeemFee;
}
