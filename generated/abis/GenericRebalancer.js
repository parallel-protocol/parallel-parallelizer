export const Abi_GenericRebalancer = /** @type {const} **/ ([
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "initialTokenTransferAddress",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "initialSwapRouter",
        "type": "address"
      },
      {
        "internalType": "contract ITokenP",
        "name": "definitivetokenP",
        "type": "address"
      },
      {
        "internalType": "contract IParallelizer",
        "name": "definitiveParallelizer",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "initialAuthority",
        "type": "address"
      },
      {
        "internalType": "contract IERC3156FlashLender",
        "name": "definitiveFlashloan",
        "type": "address"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
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
    "name": "NotTrusted",
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
    "inputs": [],
    "name": "SwapError",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "ZeroAddress",
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
        "name": "token",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "spender",
        "type": "address"
      }
    ],
    "name": "AllowanceReset",
    "type": "event"
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
        "name": "newSwapRouter",
        "type": "address"
      }
    ],
    "name": "SwapRouterUpdated",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "newTokenTransferAddress",
        "type": "address"
      }
    ],
    "name": "TokenTransferAddressUpdated",
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
    "name": "CALLBACK_SUCCESS",
    "outputs": [
      {
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      },
      {
        "internalType": "address",
        "name": "receiver",
        "type": "address"
      }
    ],
    "name": "addBudget",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
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
        "name": "",
        "type": "address"
      }
    ],
    "name": "budget",
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
    "inputs": [],
    "name": "flashloan",
    "outputs": [
      {
        "internalType": "contract IERC3156FlashLender",
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
        "name": "initiator",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "fee",
        "type": "uint256"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      }
    ],
    "name": "onFlashLoan",
    "outputs": [
      {
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      }
    ],
    "stateMutability": "nonpayable",
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
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      },
      {
        "internalType": "address",
        "name": "receiver",
        "type": "address"
      }
    ],
    "name": "removeBudget",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "token",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "spender",
        "type": "address"
      }
    ],
    "name": "resetAllowance",
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
        "internalType": "uint64",
        "name": "newMaxSlippage",
        "type": "uint64"
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
        "name": "newSwapRouter",
        "type": "address"
      }
    ],
    "name": "setSwapRouter",
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
        "name": "newTokenTransferAddress",
        "type": "address"
      }
    ],
    "name": "setTokenTransferAddress",
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
        "internalType": "uint64",
        "name": "maxSlippage",
        "type": "uint64"
      }
    ],
    "name": "setYieldBearingAssetData",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "swapRouter",
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
    "inputs": [],
    "name": "tokenTransferAddress",
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
        "internalType": "uint64",
        "name": "maxSlippage",
        "type": "uint64"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  }
]);