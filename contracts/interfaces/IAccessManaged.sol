// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;

/// @title IAccessManaged
/// @author Angle Labs, Inc.
interface IAccessManaged {
    /// @notice Checks whether an address is governor of the Angle Protocol or not
    /// @param admin Address to check
    /// @return Whether the address has the `GOVERNOR_ROLE` or not
    function isGovernor(address admin) external view returns (bool);

    /// @notice Checks whether an address is governor or a guardian of the Angle Protocol or not
    /// @param admin Address to check
    /// @return Whether the address has the `GUARDIAN_ROLE` or not
    /// @dev Governance should make sure when adding a governor to also give this governor the guardian
    /// role by calling the `addGovernor` function
    function isGuardian(address admin) external view returns (bool);

    /// @notice Checks whether a caller can call a function with a given selector
    /// @param caller Caller address
    /// @param data Calldata of the function to call
    /// @return Whether the caller can call the function
    function canCall(address caller, bytes calldata data) external view returns (bool);
}
