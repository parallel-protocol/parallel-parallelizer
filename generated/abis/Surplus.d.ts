export type Abi_Surplus = [
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
    "name": "SurplusBufferRatioNotSet",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "Undercollateralized",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "ZeroAmount",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "ZeroSurplusAmount",
    "type": "error"
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
        "indexed": false,
        "internalType": "address",
        "name": "collateral",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "collateralSurplus",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "stableSurplus",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "issuedAmount",
        "type": "uint256"
      }
    ],
    "name": "SurplusProcessed",
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
        "internalType": "uint256",
        "name": "maxCollateralAmount",
        "type": "uint256"
      }
    ],
    "name": "processSurplus",
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
      },
      {
        "internalType": "uint256",
        "name": "issuedAmount",
        "type": "uint256"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "release",
    "outputs": [
      {
        "internalType": "address[]",
        "name": "payees",
        "type": "address[]"
      },
      {
        "internalType": "uint256[]",
        "name": "amounts",
        "type": "uint256[]"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];
export declare const Abi_Surplus: Abi_Surplus;
