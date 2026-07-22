export const Abi_SettersGuardian = /** @type {const} **/ ([
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
    "name": "AlreadyPaused",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "InvalidNegativeFees",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "InvalidParams",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "NotCollateral",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "NotGovernor",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "NotPaused",
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
    "name": "pause",
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
        "internalType": "uint64[]",
        "name": "xFee",
        "type": "uint64[]"
      },
      {
        "internalType": "int64[]",
        "name": "yFee",
        "type": "int64[]"
      },
      {
        "internalType": "bool",
        "name": "mint",
        "type": "bool"
      }
    ],
    "name": "setFees",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint64[]",
        "name": "xFee",
        "type": "uint64[]"
      },
      {
        "internalType": "int64[]",
        "name": "yFee",
        "type": "int64[]"
      }
    ],
    "name": "setRedemptionCurveParams",
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
        "name": "stablecoinCap",
        "type": "uint256"
      }
    ],
    "name": "setStablecoinCap",
    "outputs": [],
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
        "name": "who",
        "type": "address"
      }
    ],
    "name": "toggleWhitelist",
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
        "internalType": "enum ActionType",
        "name": "action",
        "type": "uint8"
      }
    ],
    "name": "unpause",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]);