export type Abi_IRedeemer = [
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "quoteRedemptionCurve",
    "outputs": [
      {
        "internalType": "address[]",
        "name": "tokens",
        "type": "address[]"
      },
      {
        "internalType": "uint256[]",
        "name": "amounts",
        "type": "uint256[]"
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
      },
      {
        "internalType": "uint256",
        "name": "deadline",
        "type": "uint256"
      },
      {
        "internalType": "uint256[]",
        "name": "minAmountOuts",
        "type": "uint256[]"
      },
      {
        "internalType": "bytes32",
        "name": "expectedTokensHash",
        "type": "bytes32"
      }
    ],
    "name": "redeem",
    "outputs": [
      {
        "internalType": "address[]",
        "name": "tokens",
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
      },
      {
        "internalType": "uint256",
        "name": "deadline",
        "type": "uint256"
      },
      {
        "internalType": "uint256[]",
        "name": "minAmountOuts",
        "type": "uint256[]"
      },
      {
        "internalType": "address[]",
        "name": "forfeitTokens",
        "type": "address[]"
      },
      {
        "internalType": "bytes32",
        "name": "expectedTokensHash",
        "type": "bytes32"
      },
      {
        "internalType": "bytes",
        "name": "authData",
        "type": "bytes"
      }
    ],
    "name": "redeemWithAuthorization",
    "outputs": [
      {
        "internalType": "address[]",
        "name": "tokens",
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
      },
      {
        "internalType": "uint256",
        "name": "deadline",
        "type": "uint256"
      },
      {
        "internalType": "uint256[]",
        "name": "minAmountOuts",
        "type": "uint256[]"
      },
      {
        "internalType": "address[]",
        "name": "forfeitTokens",
        "type": "address[]"
      },
      {
        "internalType": "bytes32",
        "name": "expectedTokensHash",
        "type": "bytes32"
      }
    ],
    "name": "redeemWithForfeit",
    "outputs": [
      {
        "internalType": "address[]",
        "name": "tokens",
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
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      },
      {
        "internalType": "bool",
        "name": "increase",
        "type": "bool"
      }
    ],
    "name": "updateNormalizer",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];
export declare const Abi_IRedeemer: Abi_IRedeemer;
