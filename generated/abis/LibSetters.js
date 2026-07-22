export const Abi_LibSetters = /** @type {const} **/ ([
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
        "indexed": true,
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint64[]",
        "name": "xFee",
        "type": "uint64[]"
      },
      {
        "indexed": false,
        "internalType": "int64[]",
        "name": "yFee",
        "type": "int64[]"
      },
      {
        "indexed": false,
        "internalType": "bool",
        "name": "mint",
        "type": "bool"
      }
    ],
    "name": "FeesSet",
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
        "name": "collateral",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "pausedType",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "bool",
        "name": "isPaused",
        "type": "bool"
      }
    ],
    "name": "PauseToggled",
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
        "indexed": false,
        "internalType": "uint64[]",
        "name": "xFee",
        "type": "uint64[]"
      },
      {
        "indexed": false,
        "internalType": "int64[]",
        "name": "yFee",
        "type": "int64[]"
      }
    ],
    "name": "RedemptionCurveParamsSet",
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
        "indexed": true,
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "stablecoinCap",
        "type": "uint256"
      }
    ],
    "name": "StablecoinCapSet",
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
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "enum WhitelistType",
        "name": "whitelistType",
        "type": "uint8"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "who",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "whitelistStatus",
        "type": "uint256"
      }
    ],
    "name": "WhitelistStatusToggled",
    "type": "event"
  }
]);