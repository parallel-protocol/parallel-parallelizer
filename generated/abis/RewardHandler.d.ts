export type Abi_RewardHandler = [
  {
    "inputs": [],
    "name": "InvalidSwap",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "InvalidTokens",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "NotTrusted",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "OdosSwapFailed",
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
    "name": "TooSmallAmountOut",
    "type": "error"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "tokenObtained",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "balanceUpdate",
        "type": "uint256"
      }
    ],
    "name": "RewardsSoldFor",
    "type": "event"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "minAmountOut",
        "type": "uint256"
      },
      {
        "internalType": "bytes",
        "name": "payload",
        "type": "bytes"
      }
    ],
    "name": "sellRewards",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "amountOut",
        "type": "uint256"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];
export declare const Abi_RewardHandler: Abi_RewardHandler;
