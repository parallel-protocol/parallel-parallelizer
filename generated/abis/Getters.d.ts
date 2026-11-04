export type Abi_Getters = [
  {
    "inputs": [],
    "name": "InvalidChainlinkRate",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "NotCollateral",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "ReentrantCall",
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
    "inputs": [],
    "name": "SurplusBufferRatioNotSet",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "ZeroSurplusAmount",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "accessManager",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
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
    "name": "getCollateralBurnFees",
    "outputs": [
      {
        "internalType": "uint64[]",
        "name": "xFeeBurn",
        "type": "uint64[]"
      },
      {
        "internalType": "int64[]",
        "name": "yFeeBurn",
        "type": "int64[]"
      }
    ],
    "stateMutability": "view",
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
    "name": "getCollateralDecimals",
    "outputs": [
      {
        "internalType": "uint8",
        "name": "",
        "type": "uint8"
      }
    ],
    "stateMutability": "view",
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
    "name": "getCollateralInfo",
    "outputs": [
      {
        "components": [
          {
            "internalType": "uint8",
            "name": "isManaged",
            "type": "uint8"
          },
          {
            "internalType": "uint8",
            "name": "isMintLive",
            "type": "uint8"
          },
          {
            "internalType": "uint8",
            "name": "isBurnLive",
            "type": "uint8"
          },
          {
            "internalType": "uint8",
            "name": "decimals",
            "type": "uint8"
          },
          {
            "internalType": "uint8",
            "name": "onlyWhitelisted",
            "type": "uint8"
          },
          {
            "internalType": "uint216",
            "name": "normalizedStables",
            "type": "uint216"
          },
          {
            "internalType": "uint64[]",
            "name": "xFeeMint",
            "type": "uint64[]"
          },
          {
            "internalType": "int64[]",
            "name": "yFeeMint",
            "type": "int64[]"
          },
          {
            "internalType": "uint64[]",
            "name": "xFeeBurn",
            "type": "uint64[]"
          },
          {
            "internalType": "int64[]",
            "name": "yFeeBurn",
            "type": "int64[]"
          },
          {
            "internalType": "bytes",
            "name": "oracleConfig",
            "type": "bytes"
          },
          {
            "internalType": "bytes",
            "name": "whitelistData",
            "type": "bytes"
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
          },
          {
            "internalType": "uint256",
            "name": "stablecoinCap",
            "type": "uint256"
          }
        ],
        "internalType": "struct Collateral",
        "name": "",
        "type": "tuple"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getCollateralList",
    "outputs": [
      {
        "internalType": "address[]",
        "name": "",
        "type": "address[]"
      }
    ],
    "stateMutability": "view",
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
    "name": "getCollateralMintFees",
    "outputs": [
      {
        "internalType": "uint64[]",
        "name": "xFeeMint",
        "type": "uint64[]"
      },
      {
        "internalType": "int64[]",
        "name": "yFeeMint",
        "type": "int64[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getCollateralRatio",
    "outputs": [
      {
        "internalType": "uint64",
        "name": "collatRatio",
        "type": "uint64"
      },
      {
        "internalType": "uint256",
        "name": "stablecoinsIssued",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
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
    "name": "getCollateralSurplus",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "collateralSurplus",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "stableSurplus",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
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
    "name": "getCollateralWhitelistData",
    "outputs": [
      {
        "internalType": "bytes",
        "name": "",
        "type": "bytes"
      }
    ],
    "stateMutability": "view",
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
    "name": "getIssuedByCollateral",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "stablecoinsFromCollateral",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "stablecoinsIssued",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getLastReleasedAt",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
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
    "name": "getManagerData",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      },
      {
        "internalType": "contract IERC20[]",
        "name": "",
        "type": "address[]"
      },
      {
        "internalType": "bytes",
        "name": "",
        "type": "bytes"
      }
    ],
    "stateMutability": "view",
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
    "name": "getOracle",
    "outputs": [
      {
        "internalType": "enum OracleReadType",
        "name": "oracleType",
        "type": "uint8"
      },
      {
        "internalType": "enum OracleReadType",
        "name": "targetType",
        "type": "uint8"
      },
      {
        "internalType": "bytes",
        "name": "oracleData",
        "type": "bytes"
      },
      {
        "internalType": "bytes",
        "name": "targetData",
        "type": "bytes"
      },
      {
        "internalType": "bytes",
        "name": "hyperparameters",
        "type": "bytes"
      }
    ],
    "stateMutability": "view",
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
    "name": "getOracleValues",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "mint",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "burn",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "ratio",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "minRatio",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "redemption",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getPayees",
    "outputs": [
      {
        "internalType": "address[]",
        "name": "",
        "type": "address[]"
      },
      {
        "internalType": "uint256[]",
        "name": "",
        "type": "uint256[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getRedemptionFees",
    "outputs": [
      {
        "internalType": "uint64[]",
        "name": "xRedemptionCurve",
        "type": "uint64[]"
      },
      {
        "internalType": "int64[]",
        "name": "yRedemptionCurve",
        "type": "int64[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "payee",
        "type": "address"
      }
    ],
    "name": "getShares",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
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
    "name": "getSlippageTolerance",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
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
    "name": "getStablecoinCap",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getSurplusBufferRatio",
    "outputs": [
      {
        "internalType": "uint64",
        "name": "",
        "type": "uint64"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getSwapRouter",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getTotalIssued",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getTotalShares",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "isConsumingScheduledOp",
    "outputs": [
      {
        "internalType": "bytes4",
        "name": "",
        "type": "bytes4"
      }
    ],
    "stateMutability": "view",
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
        "internalType": "enum ActionType",
        "name": "action",
        "type": "uint8"
      }
    ],
    "name": "isPaused",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "sender",
        "type": "address"
      }
    ],
    "name": "isTrusted",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "sender",
        "type": "address"
      }
    ],
    "name": "isTrustedSeller",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes4",
        "name": "selector",
        "type": "bytes4"
      }
    ],
    "name": "isValidSelector",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
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
    "name": "isWhitelistedCollateral",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
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
        "internalType": "address",
        "name": "sender",
        "type": "address"
      }
    ],
    "name": "isWhitelistedForCollateral",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "enum WhitelistType",
        "name": "whitelistType",
        "type": "uint8"
      },
      {
        "internalType": "address",
        "name": "sender",
        "type": "address"
      }
    ],
    "name": "isWhitelistedForType",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "tokenP",
    "outputs": [
      {
        "internalType": "contract ITokenP",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  }
];
export declare const Abi_Getters: Abi_Getters;
