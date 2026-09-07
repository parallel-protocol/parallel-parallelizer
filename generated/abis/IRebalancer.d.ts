export type Abi_IRebalancer = [
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
        "internalType": "address",
        "name": "stablecoin",
        "type": "address"
      },
      {
        "internalType": "uint64",
        "name": "targetExposure",
        "type": "uint64"
      },
      {
        "internalType": "uint64",
        "name": "minExposureYieldAsset",
        "type": "uint64"
      },
      {
        "internalType": "uint64",
        "name": "maxExposureYieldAsset",
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
        "name": "yieldBearingAsset",
        "type": "address"
      }
    ],
    "name": "updateLimitExposuresYieldAsset",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];
export declare const Abi_IRebalancer: Abi_IRebalancer;
