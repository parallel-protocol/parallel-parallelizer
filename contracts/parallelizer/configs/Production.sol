// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import "./ProductionTypes.sol";

/// @dev This contract is used only once to initialize the diamond proxy.
contract Production {
  function initialize(
    IAccessManager _accessManager,
    address _tokenP,
    CollateralSetup[] memory _collaterals,
    RedemptionSetup memory _redemptionSetup
  )
    external
  {
    // // Set Collaterals
    // CollateralSetupProd[] memory collaterals = new CollateralSetupProd[](1);
    // // USDC
    // {
    //   uint64[] memory xMintFeeUsdc = new uint64[](1);
    //   xMintFeeUsdc[0] = uint64(0);

    //   int64[] memory yMintFeeUsdc = new int64[](1);
    //   yMintFeeUsdc[0] = int64(0);

    //   uint64[] memory xBurnFeeUsdc = new uint64[](1);
    //   xBurnFeeUsdc[0] = uint64(BASE_9);

    //   int64[] memory yBurnFeeUsdc = new int64[](1);
    //   yBurnFeeUsdc[0] = int64(0);

    //   bytes memory oracleConfig;
    //   {
    //     bytes memory readData;
    //     {
    //       AggregatorV3Interface[] memory circuitChainlink = new AggregatorV3Interface[](1);
    //       uint32[] memory stalePeriods = new uint32[](1);
    //       uint8[] memory circuitChainIsMultiplied = new uint8[](1);
    //       uint8[] memory chainlinkDecimals = new uint8[](1);

    //       // Chainlink USDC/USD oracle
    //       circuitChainlink[0] = AggregatorV3Interface(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6);
    //       stalePeriods[0] = 1 days;
    //       circuitChainIsMultiplied[0] = 1;
    //       chainlinkDecimals[0] = 8;
    //       OracleQuoteType quoteType = OracleQuoteType.UNIT;
    //       readData = abi.encode(circuitChainlink, stalePeriods, circuitChainIsMultiplied, chainlinkDecimals,
    // quoteType);
    //     }
    //     bytes memory targetData;
    //     oracleConfig = abi.encode(
    //       Storage.OracleReadType.CHAINLINK_FEEDS,
    //       Storage.OracleReadType.STABLE,
    //       readData,
    //       targetData,
    //       abi.encode(uint128(0), uint128(50 * BPS))
    //     );
    //   }
    //   collaterals[0] = CollateralSetupProd(USDC, oracleConfig, xMintFeeUsdc, yMintFeeUsdc, xBurnFeeUsdc,
    // yBurnFeeUsdc);
    // }

    LibSetters.setAccessManager(_accessManager);

    ParallelizerStorage storage ts = s.transmuterStorage();
    ts.statusReentrant = NOT_ENTERED;
    ts.normalizer = uint128(BASE_27);
    ts.tokenP = ITokenP(_tokenP);

    // Setup each collateral
    uint256 collateralsLength = _collaterals.length;
    for (uint256 i; i < collateralsLength; i++) {
      CollateralSetup memory collateral = _collaterals[i];
      LibSetters.addCollateral(collateral.token);
      LibSetters.setOracle(collateral.token, collateral.oracleConfig);
      // Mint fees
      LibSetters.setFees(collateral.token, collateral.xMintFee, collateral.yMintFee, true);
      // Burn fees
      LibSetters.setFees(collateral.token, collateral.xBurnFee, collateral.yBurnFee, false);
      LibSetters.togglePause(collateral.token, ActionType.Mint);
      LibSetters.togglePause(collateral.token, ActionType.Burn);
    }

    // setRedemptionCurveParams
    if (_redemptionSetup.xRedeemFee.length > 0) {
      LibSetters.togglePause(address(0), ActionType.Redeem);
      LibSetters.setRedemptionCurveParams(_redemptionSetup.xRedeemFee, _redemptionSetup.yRedeemFee);
    }
  }
}
