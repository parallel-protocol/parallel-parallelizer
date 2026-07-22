export type Abi_SettersGovernor = [
  {
    "inputs": [],
    "name": "AboveCap",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "caller",
        "type": "address"
      }
    ],
    "name": "AccessManagedUnauthorized",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "AlreadyAdded",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "ArrayLengthMismatch",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "CollateralBacked",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "InvalidAccessManager",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "InvalidChainlinkRate",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "InvalidLengths",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "InvalidParam",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "InvalidParams",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "InvalidRate",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "InvalidWhitelistStatus",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "ManagerHasAssets",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "NotCollateral",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "NotTrusted",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "OracleUpdateFailed",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "uint8",
        "name": "bits",
        "type": "uint8"
      },
      {
        "internalType": "uint256",
        "name": "value",
        "type": "uint256"
      }
    ],
    "name": "SafeCastOverflowedUintDowncast",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "spender",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "currentAllowance",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "requestedDecrease",
        "type": "uint256"
      }
    ],
    "name": "SafeERC20FailedDecreaseAllowance",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "token",
        "type": "address"
      }
    ],
    "name": "SafeERC20FailedOperation",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "ZeroAmount",
    "type": "error"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      }
    ],
    "name": "CollateralAdded",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "collateral",
        "type": "address"
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
        "indexed": false,
        "internalType": "struct ManagerStorage",
        "name": "managerData",
        "type": "tuple"
      }
    ],
    "name": "CollateralManagerSet",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      }
    ],
    "name": "CollateralRevoked",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "bytes",
        "name": "whitelistData",
        "type": "bytes"
      },
      {
        "indexed": false,
        "internalType": "uint8",
        "name": "whitelistStatus",
        "type": "uint8"
      }
    ],
    "name": "CollateralWhitelistStatusUpdated",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "income",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "releasedAt",
        "type": "uint256"
      }
    ],
    "name": "IncomeReleased",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "income",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "payee",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "releasedAt",
        "type": "uint256"
      }
    ],
    "name": "IncomeReleasedToPayee",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "bytes",
        "name": "oracleConfig",
        "type": "bytes"
      }
    ],
    "name": "OracleSet",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "previousOwner",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "OwnershipTransferred",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "payee",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "shares",
        "type": "uint256"
      }
    ],
    "name": "PayeeAdded",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "token",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "to",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "Recovered",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "bool",
        "name": "increase",
        "type": "bool"
      }
    ],
    "name": "ReservesAdjusted",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "slippageTolerance",
        "type": "uint256"
      }
    ],
    "name": "SlippageToleranceUpdated",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "uint64",
        "name": "surplusBufferRatio",
        "type": "uint64"
      }
    ],
    "name": "SurplusBufferRatioUpdated",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "sender",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "bool",
        "name": "isTrusted",
        "type": "bool"
      },
      {
        "indexed": false,
        "internalType": "enum TrustedType",
        "name": "trustedType",
        "type": "uint8"
      }
    ],
    "name": "TrustedToggled",
    "type": "event"
  },
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
];
export declare const Abi_SettersGovernor: Abi_SettersGovernor;
