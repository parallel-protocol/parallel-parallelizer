// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

/// @title IHarvester
/// @author Cooper Labs
/// @custom:contact security@cooperlabs.xyz
/// @dev This interface is an authorized fork of Angle's `IHarvester` interface
/// https://github.com/AngleProtocol/angle-transmuter/blob/main/contracts/interfaces/IHarvester.sol
interface IHarvester {
  function setYieldBearingAssetData(
    address yieldBearingAsset,
    address stablecoin,
    uint64 targetExposure,
    uint64 minExposureYieldAsset,
    uint64 maxExposureYieldAsset,
    uint64 overrideExposures
  )
    external;

  function updateLimitExposuresYieldAsset(address yieldBearingAsset) external;

  function setMaxSlippage(uint96 newMaxSlippage) external;

  function harvest(address yieldBearingAsset, uint256 scale, bytes calldata extraData) external;
}
