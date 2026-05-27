// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "./Base.s.sol";

import { ISettersGuardian, ISettersGovernor } from "contracts/interfaces/ISetters.sol";
import { ActionType, OracleReadType, OracleQuoteType } from "contracts/parallelizer/Storage.sol";

/// @notice Adds the EIP-3009 Mock USDC (mUSDC) deployed on Sepolia as a new collateral of the
/// USDp Parallelizer, reusing the exact same oracle configuration and fee curves as the existing
/// USDC collateral. The broadcaster must hold both the GOVERNOR and GUARDIAN roles.
contract AddCollateralMUSDC is BaseScript {
  // USDp Parallelizer diamond proxy (deployments/sepolia/Parallelizer_USDp.json)
  address constant PARALLELIZER = 0xd8cc2A51556Da84b5DB309e86f30Ff98B5309862;

  // New EIP-3009 Mock USDC collateral (6 decimals)
  address constant COLLATERAL = 0xA5B6c0C6AFbfb5C8808ec3ad3db9098A6b82433a;

  // Chainlink USDC/USD feed already used by the existing USDC collateral
  address constant CHAINLINK_USDC_USD = 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E;

  function run() public broadcast {
    bytes memory oracleConfig = _buildOracleConfig();

    // --- GOVERNOR ---
    ISettersGovernor(PARALLELIZER).addCollateral(COLLATERAL);
    ISettersGovernor(PARALLELIZER).setOracle(COLLATERAL, oracleConfig);

    // --- GUARDIAN ---
    ISettersGuardian(PARALLELIZER).setFees(COLLATERAL, _mintXFee(), _mintYFee(), true);
    ISettersGuardian(PARALLELIZER).setFees(COLLATERAL, _burnXFee(), _burnYFee(), false);
    ISettersGuardian(PARALLELIZER).togglePause(COLLATERAL, ActionType.Mint);
    ISettersGuardian(PARALLELIZER).togglePause(COLLATERAL, ActionType.Burn);
    ISettersGuardian(PARALLELIZER).setStablecoinCap(COLLATERAL, 100_000_000 ether);
  }

  /// @dev Mirrors the `oracle` block of the existing USDC collateral in
  /// deploy/config/sepolia/config.json: CHAINLINK_FEEDS / STABLE / UNIT.
  function _buildOracleConfig() internal pure returns (bytes memory) {
    address[] memory circuitChainlink = new address[](1);
    circuitChainlink[0] = CHAINLINK_USDC_USD;

    uint32[] memory stalePeriods = new uint32[](1);
    stalePeriods[0] = 86_400;

    uint8[] memory circuitChainIsMultiplied = new uint8[](1);
    circuitChainIsMultiplied[0] = 1;

    uint8[] memory chainlinkDecimals = new uint8[](1);
    chainlinkDecimals[0] = 8;

    bytes memory readData = abi.encode(
      circuitChainlink, stalePeriods, circuitChainIsMultiplied, chainlinkDecimals, OracleQuoteType.UNIT
    );
    // STABLE target type does not require target data.
    bytes memory targetData = "";
    // hyperparameters: (userDeviation, burnRatioDeviation)
    bytes memory hyperparameters = abi.encode(uint128(0), uint128(5_000_000_000_000_000));

    return abi.encode(OracleReadType.CHAINLINK_FEEDS, OracleReadType.STABLE, readData, targetData, hyperparameters);
  }

  function _mintXFee() internal pure returns (uint64[] memory x) {
    x = new uint64[](3);
    x[0] = 0;
    x[1] = 940_000_000;
    x[2] = 950_000_000;
  }

  function _mintYFee() internal pure returns (int64[] memory y) {
    y = new int64[](3);
    y[0] = 500_000;
    y[1] = 500_000;
    y[2] = 999_999_999_999;
  }

  function _burnXFee() internal pure returns (uint64[] memory x) {
    x = new uint64[](3);
    x[0] = 1_000_000_000;
    x[1] = 310_000_000;
    x[2] = 300_000_000;
  }

  function _burnYFee() internal pure returns (int64[] memory y) {
    y = new int64[](3);
    y[0] = 500_000;
    y[1] = 500_000;
    y[2] = 999_000_000;
  }
}
