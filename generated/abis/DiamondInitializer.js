export const Abi_DiamondInitializer = /** @type {const} **/ ([
  {
    "inputs": [],
    "name": "AlreadyAdded",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "AlreadyPaused",
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
    "inputs": [],
    "name": "OracleUpdateFailed",
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
    "inputs": [
      {
        "internalType": "contract IAccessManager",
        "name": "_accessManager",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "_tokenP",
        "type": "address"
      },
      {
        "components": [
          {
            "internalType": "address",
            "name": "token",
            "type": "address"
          },
          {
            "internalType": "bool",
            "name": "targetMax",
            "type": "bool"
          },
          {
            "internalType": "bytes",
            "name": "oracleConfig",
            "type": "bytes"
          },
          {
            "internalType": "uint64[]",
            "name": "xMintFee",
            "type": "uint64[]"
          },
          {
            "internalType": "int64[]",
            "name": "yMintFee",
            "type": "int64[]"
          },
          {
            "internalType": "uint64[]",
            "name": "xBurnFee",
            "type": "uint64[]"
          },
          {
            "internalType": "int64[]",
            "name": "yBurnFee",
            "type": "int64[]"
          }
        ],
        "internalType": "struct CollateralSetup[]",
        "name": "_collaterals",
        "type": "tuple[]"
      },
      {
        "components": [
          {
            "internalType": "uint64[]",
            "name": "xRedeemFee",
            "type": "uint64[]"
          },
          {
            "internalType": "int64[]",
            "name": "yRedeemFee",
            "type": "int64[]"
          }
        ],
        "internalType": "struct RedemptionSetup",
        "name": "_redemptionSetup",
        "type": "tuple"
      }
    ],
    "name": "initialize",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]);