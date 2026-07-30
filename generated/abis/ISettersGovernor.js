export const Abi_ISettersGovernor = /** @type {const} **/ ([
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      }
    ],
    "name": "addCollateral",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      },
      {
        "internalType": "uint128",
        "name": "amount",
        "type": "uint128"
      },
      {
        "internalType": "bool",
        "name": "increase",
        "type": "bool"
      }
    ],
    "name": "adjustStablecoins",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "contract IERC20",
        "name": "token",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "spender",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "changeAllowance",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      },
      {
        "internalType": "contract IERC20",
        "name": "token",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "to",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "recoverERC20",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      },
      {
        "internalType": "bool",
        "name": "checkExternalManagerBalance",
        "type": "bool"
      }
    ],
    "name": "revokeCollateral",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_newAccessManager",
        "type": "address"
      }
    ],
    "name": "setAccessManager",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      },
      {
        "internalType": "bool",
        "name": "checkExternalManagerBalance",
        "type": "bool"
      },
      {
        "components": [
          {
            "internalType": "contract IERC20[]",
            "name": "subCollaterals",
            "type": "address[]"
          },
          {
            "internalType": "bytes",
            "name": "config",
            "type": "bytes"
          }
        ],
        "internalType": "struct ManagerStorage",
        "name": "managerData",
        "type": "tuple"
      }
    ],
    "name": "setCollateralManager",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      },
      {
        "internalType": "bytes",
        "name": "oracleConfig",
        "type": "bytes"
      }
    ],
    "name": "setOracle",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      },
      {
        "internalType": "uint8",
        "name": "whitelistStatus",
        "type": "uint8"
      },
      {
        "internalType": "bytes",
        "name": "whitelistData",
        "type": "bytes"
      }
    ],
    "name": "setWhitelistStatus",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "sender",
        "type": "address"
      },
      {
        "internalType": "enum TrustedType",
        "name": "t",
        "type": "uint8"
      }
    ],
    "name": "toggleTrusted",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      }
    ],
    "name": "updateOracle",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address[]",
        "name": "_payees",
        "type": "address[]"
      },
      {
        "internalType": "uint256[]",
        "name": "_shares",
        "type": "uint256[]"
      },
      {
        "internalType": "bool",
        "name": "_skipRelease",
        "type": "bool"
      }
    ],
    "name": "updatePayees",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "slippageTolerance",
        "type": "uint256"
      }
    ],
    "name": "updateSlippageTolerance",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint64",
        "name": "_surplusBufferRatio",
        "type": "uint64"
      }
    ],
    "name": "updateSurplusBufferRatio",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]);