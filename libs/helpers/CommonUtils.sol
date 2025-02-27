// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import {CommonBase, VmSafe} from "@forge-std/Base.sol";
import {Test} from "@forge-std/Test.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {JsonReader} from "./JsonReader.sol";
import {strings} from "@stringutils/strings.sol";
import {ContractType, Constants} from "@helpers/Constants.sol";

contract CommonUtils is CommonBase, JsonReader {
    using strings for *;
    bytes32 private constant EUR_HASH = keccak256(abi.encodePacked("EUR"));
    bytes32 private constant USD_HASH = keccak256(abi.encodePacked("USD"));

    

    function _getAllContracts(
        uint256 chainId
    ) internal view returns (address[] memory) {
        string memory json = readJsonFile(getPath());

        // Get all keys at the chain level (these are the contract categories)
        string memory chainPath = string.concat(".", vm.toString(chainId));
        string[] memory keys = vm.parseJsonKeys(json, chainPath);

        // Create dynamic arrays to store addresses
        address[] memory addresses = new address[](100); // Initial size
        uint256 count = 0;

        // Iterate through each key to collect addresses
        for (uint256 i = 0; i < keys.length; i++) {
            string memory key = keys[i];
            string memory fullPath = string.concat(chainPath, ".", key);

            // Try to parse as direct address
            try vm.parseJsonAddress(json, fullPath) returns (address addr) {
                if (addr != address(0)) {
                    addresses[count++] = addr;
                }
            } catch {
                // If not a direct address, try to parse nested objects
                try vm.parseJsonKeys(json, fullPath) returns (
                    string[] memory subKeys
                ) {
                    for (uint256 j = 0; j < subKeys.length; j++) {
                        string memory subPath = string.concat(
                            fullPath,
                            ".",
                            subKeys[j]
                        );
                        try vm.parseJsonAddress(json, subPath) returns (
                            address addr
                        ) {
                            if (addr != address(0)) {
                                addresses[count++] = addr;
                            }
                        } catch {}
                    }
                } catch {}
            }
        }

        // Create final array with exact size
        address[] memory result = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = addresses[i];
        }

        return result;
    }

    function _getConnectedChains(
        string memory token
    ) internal returns (uint256[] memory, address[] memory) {
        uint256[] memory allChainIds = _getChainIds();
        uint256[] memory chainIds = new uint256[](0);
        address[] memory contracts = new address[](0);

        for (uint256 i = 0; i < allChainIds.length; i++) {
            address addr;
            if (keccak256(abi.encodePacked(token)) == EUR_HASH) {
                try
                    this.chainToContract(allChainIds[i], ContractType.LZEURp)
                returns (address _addr) {
                    addr = _addr;
                } catch {}
            } else if (keccak256(abi.encodePacked(token)) == USD_HASH) {
                try
                    this.chainToContract(allChainIds[i], ContractType.LZUSDp)
                returns (address _addr) {
                    addr = _addr;
                } catch {}
            } 

            if (addr != address(0)) {
                assembly {
                    // Get the current length of the arrays
                    let oldLen := mload(chainIds)
                    let newLen := add(oldLen, 1)

                    // Calculate new memory locations
                    let newChainIds := add(mload(0x40), 0x20)
                    let newContracts := add(
                        newChainIds,
                        mul(add(newLen, 1), 0x20)
                    )

                    // Store lengths
                    mstore(newChainIds, newLen)
                    mstore(newContracts, newLen)

                    // Copy existing chainIds
                    let srcChainIds := add(chainIds, 0x20)
                    let destChainIds := add(newChainIds, 0x20)
                    for {
                        let j := 0
                    } lt(j, oldLen) {
                        j := add(j, 1)
                    } {
                        mstore(
                            add(destChainIds, mul(j, 0x20)),
                            mload(add(srcChainIds, mul(j, 0x20)))
                        )
                    }

                    // Copy existing contracts
                    let srcContracts := add(contracts, 0x20)
                    let destContracts := add(newContracts, 0x20)
                    for {
                        let j := 0
                    } lt(j, oldLen) {
                        j := add(j, 1)
                    } {
                        mstore(
                            add(destContracts, mul(j, 0x20)),
                            mload(add(srcContracts, mul(j, 0x20)))
                        )
                    }

                    // Add new elements
                    mstore(
                        add(destChainIds, mul(oldLen, 0x20)),
                        mload(add(allChainIds, add(0x20, mul(i, 0x20))))
                    )
                    mstore(add(destContracts, mul(oldLen, 0x20)), addr)

                    // Update free memory pointer
                    mstore(0x40, add(newContracts, mul(add(newLen, 1), 0x20)))

                    // Update array pointers
                    chainIds := newChainIds
                    contracts := newContracts
                }
            }
        }

        return (chainIds, contracts);
    }

    /// @notice Get all chains from the SDK
    function _getChainIds() internal view returns (uint256[] memory) {
        // Parse the entire JSON object first
        string memory json = readJsonFile(getPath());

        // Get the object keys (chain IDs) at the root level
        string[] memory chainIds = vm.parseJsonKeys(json, ".");

        // Convert string array of chain IDs to uint256 array
        uint256[] memory result = new uint256[](chainIds.length);
        for (uint256 i = 0; i < chainIds.length; i++) {
            result[i] = vm.parseUint(chainIds[i]);
        }

        return result;
    }

    /// @notice Get all chains where a specific contract type is deployed
    function _getChainIdsWithDeployedContract(
        ContractType contractType
    ) internal view returns (uint256[] memory deployedChains) {
        string memory json = readJsonFile(getPath());
        string[] memory chainIds = vm.parseJsonKeys(json, ".");

        // First count how many chains have the contract deployed
        uint256 deployedCount = 0;
        for (uint256 i = 0; i < chainIds.length; i++) {
            try this.chainToContract(vm.parseUint(chainIds[i]), contractType) {
                deployedCount++;
            } catch {
                continue;
            }
        }

        // Create array of exact size and populate it
        deployedChains = new uint256[](deployedCount);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < chainIds.length; i++) {
            try this.chainToContract(vm.parseUint(chainIds[i]), contractType) {
                deployedChains[currentIndex] = vm.parseUint(chainIds[i]);
                currentIndex++;
            } catch {
                continue;
            }
        }
    }

    function chainToContract(
        uint256 chainId,
        ContractType name
    ) external view returns (address) {
        return _chainToContract(chainId, name);
    }

    function _chainToContract(
        uint256 chainId,
        ContractType name
    ) internal view returns (address) {
        return this.readAddress(chainId, _getContractPath(name));
    }

    /// @dev Helper function to get the JSON path for a contract type
    function _getContractPath(
        ContractType name
    ) internal pure returns (string memory) {
        if (name == ContractType.EURp) return "EUR.token";
        else if (name == ContractType.USDp) return "USD.token";
        else if (name == ContractType.LZEURp) return "EUR.lzToken";
        else if (name == ContractType.LZUSDp) return "USD.lzToken";
        else if (name == ContractType.PRL) return "PRL";
        else if (name == ContractType.sEURp) return "EUR.Savings";
        else if (name == ContractType.sUSDp) return "USD.Savings";
        else if (name == ContractType.Timelock) return "Timelock";
        else if (name == ContractType.TransmuterEURp) return "EUR.Transmuter";
        else if (name == ContractType.TransmuterUSDp) return "USD.Transmuter";
        else if (name == ContractType.TreasuryEURp) return "EUR.Treasury";
        else if (name == ContractType.TreasuryUSDp) return "USD.Treasury";
        else if (name == ContractType.FlashLoan) return "FlashLoan";
        else if (name == ContractType.MultiBlockHarvester)
            return "USD.MultiBlockHarvester";
        else if (name == ContractType.GenericHarvester)
            return "USD.GenericHarvester";
        else if (name == ContractType.Harvester) return "USD.Harvester";
        else if (name == ContractType.Rebalancer) return "USD.Rebalancer";
        else if (name == ContractType.MulticallWithFailure)
            return "MulticallWithFailure";
        else if (name == ContractType.OracleNativeUSD) return "OracleNativeUSD";
        else if (name == ContractType.Swapper) return "Swapper";
        else if (name == ContractType.ProxyAdmin) return "ProxyAdmin";
        else if (name == ContractType.DaoMultisig) return "DaoMultisig";
        else if (name == ContractType.GuardianMultisig) return "GuardianMultisig";

        else revert("contract not supported");
    }

    function _stringToUint(string memory s) internal pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }


    function _generateSelectors(
        string memory _facetName
    ) internal returns (bytes4[] memory selectors) {
        return _generateSelectors(_facetName, 3);
    }

    function _generateSelectors(
        string memory _facetName,
        uint256 retries
    ) internal returns (bytes4[] memory selectors) {
        //get string of contract methods
        string[] memory cmd = new string[](4);
        cmd[0] = "forge";
        cmd[1] = "inspect";
        cmd[2] = _facetName;
        cmd[3] = "methods";
        bytes memory res = vm.ffi(cmd);
        string memory st = string(res);
        // if empty, try again
        if (bytes(st).length == 0) {
            if (retries != 0) {
                return _generateSelectors(_facetName, retries - 1);
            }
        }
        // convert to slice
        strings.slice memory s = st.toSlice();

        // define delimiters
        strings.slice memory rowDelim = "\n".toSlice();
        strings.slice memory partDelim = "|".toSlice();
        strings.slice memory spaceDelim = " ".toSlice();

        // remove first line
        s.split(rowDelim);
        
        // determine number of methods
        uint256 count = s.count(rowDelim);
        count = count > 2 ? (count - 1 )/2 : count;
        selectors = new bytes4[](count);
        // remove column headers and separator lines
        s.split(rowDelim);
        s.split(rowDelim);

        for (uint i = 0; i < selectors.length; ++i) {
            strings.slice memory currentLine = s.split(rowDelim);
            // isolate method by removing space around it
            currentLine.split(spaceDelim);
            selectors[i] = bytes4(currentLine.split(spaceDelim).keccak());
            s.split(rowDelim);
        }
        return selectors;
    }


}
