export type Abi_Test = [
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
            "name": "collateral",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "oracle",
            "type": "address"
          }
        ],
        "internalType": "struct CollateralSetup",
        "name": "eurA",
        "type": "tuple"
      },
      {
        "components": [
          {
            "internalType": "address",
            "name": "collateral",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "oracle",
            "type": "address"
          }
        ],
        "internalType": "struct CollateralSetup",
        "name": "eurB",
        "type": "tuple"
      },
      {
        "components": [
          {
            "internalType": "address",
            "name": "collateral",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "oracle",
            "type": "address"
          }
        ],
        "internalType": "struct CollateralSetup",
        "name": "eurY",
        "type": "tuple"
      }
    ],
    "name": "initialize",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];
export declare const Abi_Test: Abi_Test;
