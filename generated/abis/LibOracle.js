export const Abi_LibOracle = /** @type {const} **/ ([
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
]);