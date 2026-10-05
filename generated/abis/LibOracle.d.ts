export type Abi_LibOracle = [
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
        "name": "previousTarget",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "newTarget",
        "type": "uint256"
      }
    ],
    "name": "OracleTargetUpdated",
    "type": "event"
  }
];
export declare const Abi_LibOracle: Abi_LibOracle;
