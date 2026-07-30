export const Abi_LibSurplus = /** @type {const} **/ ([
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
  }
]);