export const Abi_BaseHarvester = /** @type {const} **/ ([
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "authority",
        "type": "address"
      }
    ],
    "name": "AccessManagedInvalidAuthority",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "caller",
        "type": "address"
      },
      {
        "internalType": "uint32",
        "name": "delay",
        "type": "uint32"
      }
    ],
    "name": "AccessManagedRequiredDelay",
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
    "name": "InvalidParam",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "NotTrustedOrGuardian",
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
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "authority",
        "type": "address"
      }
    ],
    "name": "AuthorityUpdated",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "token",
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
        "internalType": "address",
        "name": "to",
        "type": "address"
      }
    ],
    "name": "Recovered",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "trusted",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "bool",
        "name": "status",
        "type": "bool"
      }
    ],
    "name": "TrustedToggled",
    "type": "event"
  },
  {
    "inputs": [],
    "name": "authority",
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
        "name": "yieldBearingAsset",
        "type": "address"
      }
    ],
    "name": "computeRebalanceAmount",
    "outputs": [
      {
        "internalType": "uint8",
        "name": "increase",
        "type": "uint8"
      },
      {
        "internalType": "uint256",
        "name": "amount",
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
        "name": "yieldBearingAsset",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "scale",
        "type": "uint256"
      },
      {
        "internalType": "bytes",
        "name": "extraData",
        "type": "bytes"
      }
    ],
    "name": "harvest",
    "outputs": [],
    "stateMutability": "nonpayable",
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
        "name": "",
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
        "name": "",
        "type": "address"
      }
    ],
    "name": "maxTokenSlippage",
    "outputs": [
      {
        "internalType": "uint96",
        "name": "",
        "type": "uint96"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "parallelizer",
    "outputs": [
      {
        "internalType": "contract IParallelizer",
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
        "name": "tokenAddress",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "amountToRecover",
        "type": "uint256"
      },
      {
        "internalType": "address",
        "name": "to",
        "type": "address"
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
        "name": "newAuthority",
        "type": "address"
      }
    ],
    "name": "setAuthority",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "yieldBearingAsset",
        "type": "address"
      },
      {
        "internalType": "uint96",
        "name": "newMaxSlippage",
        "type": "uint96"
      }
    ],
    "name": "setMaxSlippage",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "yieldBearingAsset",
        "type": "address"
      },
      {
        "internalType": "uint64",
        "name": "targetExposure",
        "type": "uint64"
      }
    ],
    "name": "setTargetExposure",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "yieldBearingAsset",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "asset",
        "type": "address"
      },
      {
        "internalType": "uint64",
        "name": "targetExposure",
        "type": "uint64"
      },
      {
        "internalType": "uint64",
        "name": "minExposure",
        "type": "uint64"
      },
      {
        "internalType": "uint64",
        "name": "maxExposure",
        "type": "uint64"
      },
      {
        "internalType": "uint64",
        "name": "overrideExposures",
        "type": "uint64"
      },
      {
        "internalType": "uint96",
        "name": "maxSlippage",
        "type": "uint96"
      }
    ],
    "name": "setYieldBearingAssetData",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "trusted",
        "type": "address"
      }
    ],
    "name": "toggleTrusted",
    "outputs": [],
    "stateMutability": "nonpayable",
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
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "yieldBearingAsset",
        "type": "address"
      }
    ],
    "name": "updateLimitExposuresYieldAsset",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "name": "yieldBearingData",
    "outputs": [
      {
        "internalType": "address",
        "name": "asset",
        "type": "address"
      },
      {
        "internalType": "uint64",
        "name": "targetExposure",
        "type": "uint64"
      },
      {
        "internalType": "uint64",
        "name": "maxExposure",
        "type": "uint64"
      },
      {
        "internalType": "uint64",
        "name": "minExposure",
        "type": "uint64"
      },
      {
        "internalType": "uint64",
        "name": "overrideExposures",
        "type": "uint64"
      },
      {
        "internalType": "uint96",
        "name": "maxSlippage",
        "type": "uint96"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  }
]);