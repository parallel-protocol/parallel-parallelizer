// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.19;

import { ISettersGuardian } from "interfaces/ISetters.sol";

import { LibSetters } from "../libraries/LibSetters.sol";
import { AccessManagedModifiers } from "./AccessManagedModifiers.sol";

import "../Storage.sol";

/// @title SettersGuardian
/// @author Angle Labs, Inc.
contract SettersGuardian is AccessManagedModifiers, ISettersGuardian {
    /// @inheritdoc ISettersGuardian
    function togglePause(address collateral, ActionType pausedType) external restricted {
        LibSetters.togglePause(collateral, pausedType);
    }

    /// @inheritdoc ISettersGuardian
    function setFees(address collateral, uint64[] memory xFee, int64[] memory yFee, bool mint) external restricted {
        LibSetters.setFees(collateral, xFee, yFee, mint);
    }

    /// @inheritdoc ISettersGuardian
    function setRedemptionCurveParams(uint64[] memory xFee, int64[] memory yFee) external restricted {
        LibSetters.setRedemptionCurveParams(xFee, yFee);
    }

    /// @inheritdoc ISettersGuardian
    function toggleWhitelist(WhitelistType whitelistType, address who) external restricted {
        LibSetters.toggleWhitelist(whitelistType, who);
    }

    /// @inheritdoc ISettersGuardian
    function setStablecoinCap(address collateral, uint256 stablecoinCap) external restricted {
        LibSetters.setStablecoinCap(collateral, stablecoinCap);
    }
}
