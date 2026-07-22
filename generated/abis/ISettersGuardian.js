export const Abi_ISettersGuardian = /** @type {const} **/ ([
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