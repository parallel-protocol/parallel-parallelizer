// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import { IDiamondCut } from "./IDiamondCut.sol";
import { IDiamondEtherscan } from "./IDiamondEtherscan.sol";
import { IDiamondLoupe } from "./IDiamondLoupe.sol";
import { IGetters } from "./IGetters.sol";
import { IRedeemer } from "./IRedeemer.sol";
import { IRewardHandler } from "./IRewardHandler.sol";
import { ISettersGovernor, ISettersGuardian } from "./ISetters.sol";
import { ISwapper } from "./ISwapper.sol";

/// @title IParallelizer
/// @author Cooper Labs
/// @custom:contact security@cooperlabs.xyz
/// @dev This interface is a friendly fork of Angle's `IParallelizer` interface
/// https://github.com/AngleProtocol/angle-transmuter/blob/main/contracts/interfaces/IParallelizer.sol
interface IParallelizer is
  IDiamondCut,
  IDiamondEtherscan,
  IDiamondLoupe,
  IGetters,
  IRedeemer,
  IRewardHandler,
  ISettersGovernor,
  ISettersGuardian,
  ISwapper
{ }
