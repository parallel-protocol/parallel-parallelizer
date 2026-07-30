export const Abi_ISurplus = /** @type {const} **/ ([
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
]);