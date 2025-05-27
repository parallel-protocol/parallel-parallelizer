# Parallel - Parallelizer

## Summary

**Parallelizer is an authorized fork of Angle's Transmuter which is an autonomous and modular price stability module for
decentralized stablecoin protocols.**

- It is conceived as a basket of different assets (normally stablecoins) backing a stablecoin and comes with guarantees
  on the maximum exposure the stablecoin can have to each asset in the basket.
- A stablecoin issued through the Parallelizer system can be minted at oracle value from any of the assets with adaptive
  fees, and it can be burnt for any of the assets in the backing with variable fees as well. It can also be redeemed at
  any time against a proportional amount of each asset in the backing.

Parallelizer is compatible with other common mechanisms often used to issue stablecoins like collateralized-debt
position models.

## Architecture

The Parallelizer system relies on a [diamond proxy pattern](https://eips.ethereum.org/EIPS/eip-2535). There is as such
only one main contract (the `Parallelizer` contract) which delegates calls to different facets each with their own
implementation. The main facets of the system are:

- the [`Swapper`](./contracts/parallelizer/facets/Swapper.sol) facet with the logic associated to the mint and burn
  functionalities of the system
- the [`Redeemer`](./contracts/parallelizer/facets/Redeemer.sol) facet for redemptions
- the [`Getters`](./contracts/parallelizer/facets/Getters.sol) facet with external getters for UIs and contracts built
  on top of `Parallelizer`
- the [`SettersGovernor`](./contracts/parallelizer/facets/SettersGovernor.sol) facet protocols' governance can use to
  update system parameters.
- the [`SettersGuardian`](./contracts/parallelizer/facets/SettersGuardian.sol) facet protocols' guardian can use to
  update system parameters.

The storage parameters of the system are defined in the [`Storage`](./contracts/parallelizer/Storage.sol) file.

The Parallelizer system can come with optional [ERC4626](https://eips.ethereum.org/EIPS/eip-4626)
[savings contracts](./contracts/savings/) which can be used to distribute a yield to the holders of the stablecoin
issued through the Parallelizer.

## Changed compared to Angle's Transmuter

Some changed has been made to the original Angle's Transmuter:

- Move from foundry gitmodule to Js dependencies
- Move from Yarn to Bun
- Move from AccessControl logics to Openzeppelin's AccessManaged
- Move from TransparentUpgradeableProxy to UUPSUpdgradeableProxy
- Restrict function to only one role due to AccessManager/AccessManaged logic (that means that Governor must also got
  Guardian role).
- Remove files that will not be used by Parallel (`SavingsVest.sol`, some `Configs/`, etc.)
- Renamed contracts (`AgToken` -> `TokenP`, `Transmuter` -> `Parallelizer`)

## Documentation Links

### Angle documentation

- [Transmuter Whitepaper](https://docs.angle.money/overview/whitepapers)
- [Angle Documentation](https://docs.angle.money)
- [Angle Developers Documentation](https://developers.angle.money)

## Deployment Addresses

### Testnet

| Contract              | Explore                                                                                                                       |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| DiamondCut Facet      | [0x9B3a8f7CEC208e247d97dEE13313690977e24459](https://sepolia.etherscan.io/address/0x9B3a8f7CEC208e247d97dEE13313690977e24459) |
| DiamondLoupe Facet    | [0xC9B6279baa19dBB8bCc3250c89cAa093AaBA0bfc](https://sepolia.etherscan.io/address/0xC9B6279baa19dBB8bCc3250c89cAa093AaBA0bfc) |
| Getters Facet         | [0x78BB4882b77D74aD9B04Ab71fE8e61f72595823C](https://sepolia.etherscan.io/address/0x78BB4882b77D74aD9B04Ab71fE8e61f72595823C) |
| Redeemer Facet        | [0x57770C1721Eb35509f38210A935c8b1911db7E0e](https://sepolia.etherscan.io/address/0x57770C1721Eb35509f38210A935c8b1911db7E0e) |
| RewardHandler Facet   | [0xad58Fc13a682a121e5fe2f8E45D4D988A7e51B0D](https://sepolia.etherscan.io/address/0xad58Fc13a682a121e5fe2f8E45D4D988A7e51B0D) |
| SettersGovernor Facet | [0xA360E5aD9F17caff53715346888aA0d13541c2F5](https://sepolia.etherscan.io/address/0xA360E5aD9F17caff53715346888aA0d13541c2F5) |
| SettersGuardian Facet | [0xa9C21Cf291ad935e0C9B05a55A42254fB159181d](https://sepolia.etherscan.io/address/0xa9C21Cf291ad935e0C9B05a55A42254fB159181d) |
| Swapper Facet         | [0x1bB46FC55E3fd91Ca0F162DCC0B3ef574C8ff97E](https://sepolia.etherscan.io/address/0x1bB46FC55E3fd91Ca0F162DCC0B3ef574C8ff97E) |
| Parallelizer USDp     | [0xd8cc2A51556Da84b5DB309e86f30Ff98B5309862](https://sepolia.etherscan.io/address/0xd8cc2A51556Da84b5DB309e86f30Ff98B5309862) |
| sUSDp (Savings)       | [0x23D491aa7C0972087F8a607F6f4c7106a02BA95d](https://sepolia.etherscan.io/address/0x23D491aa7C0972087F8a607F6f4c7106a02BA95d) |

## Security

### Trust assumptions of the Parallelizer system

The governor role, which will be a multisig or an onchain governance, has all rights, including upgrading contracts,
removing funds, changing the code, etc.

The guardian role, which will be a multisig, has the right to: freeze assets, and potentially impact transient funds.
The idea is that any malicious behavior of the guardian should be fixable by the governor, and that the guardian
shouldn't be able to extract funds from the system.

### Known Issues

- Lack of support for ERC165
- At initialization, fees need to be < 100% for 100% exposure because the first exposures will be ~100%
- If at some point there are 0 funds in the system it’ll break as `amountToNextBreakPoint` will be 0
- In the burn, if there is one asset which is making 99% of the basket, and another one 1%: if the one making 1% depegs,
  it still impacts the burn for the asset that makes the majority of the funds
- The whitelist function for burns and redemptions are somehow breaking the fairness of the system as whitelisted actors
  will redeem more value
- The `getCollateralRatio` function may overflow and revert if the amount of stablecoins issued is really small (1
  billion x smaller) than the value of the collateral in the system.

### Audits

#### Angle audits

The Angle's Transmuter and savings smart contracts have been audited by Code4rena, find the audit report
[here](https://code4rena.com/reports/2023-06-angle).

#### Parallel audits

The Parallelizer and savings contracts have been audited by:

#### Bailsec

Bailsec in April/March 2025, find the final audit report
[here](./docs/audits/Bailsec%20-%20Parallel%20Protocol%20-%20V3%20Core%20-%20Final%20Report.pdf)

#### Certora

Certora by formal verification in April/March 2025, find the final audit report
[here](./docs/audits/Certora_Report_Parallel_Parallelizer_BridgeToken_final.pdf)

## Development

This repository is built on [Foundry](https://github.com/foundry-rs/foundry).

### Getting started

#### Install Foundry

If you don't have Foundry:
[Install foundry following the instructions.](https://book.getfoundry.sh/getting-started/installation)

#### Install packages

```bash
bun install
```

### Warning

This repository uses [`ffi`](https://book.getfoundry.sh/cheatcodes/ffi) in its test suite. Beware as a malicious actor
forking this repo could add malicious commands using this.

### Setup `.env` file

```bash
PRIVATE_KEY="PRIVATE KEY"
ALCHEMY_API_KEY="ALCHEMY_API_KEY"
```

For additional keys, you can check the [`.env.example`](/.env.example) file.

**Warning: always keep your confidential information safe**

### Compilation

Compilation of production contracts will be done using the via-ir pipeline.

However, tests do not compile with via-ir, and to run coverage the optimizer needs to be off. Therefore for development
and test purposes you can compile without optimizer.

```bash
bun run compile # with via-ir but without compiling tests files
bun run compile:dev # without optimizer
```

### Testing

Here are examples of how to run the test suite:

```bash
bun run test
```

You can also list tests:

```bash
FOUNDRY_PROFILE=dev forge test --list
FOUNDRY_PROFILE=dev forge test --list --json --match-test "testXXX*"
```

### Deploying

### Coverage

We recommend the use of this [vscode extension](ryanluker.vscode-coverage-gutters).

```bash
bun run coverage
```

You'll need to install lcov `brew install lcov` to visualize the coverage report.

### Gas report

```bash
bun run gas
```

### [Slither](https://github.com/crytic/slither)

```bash
bun run slither
```

## Contributing

If you're interested in contributing, please see our [contributions guidelines](./CONTRIBUTING.md).

## Questions & Feedback

For any question or feedback you can use [discord](https://discord.com/invite/mimodao). Don't hesitate to reach out on
[Twitter](https://twitter.com/mimo_labs) as well.

## Licensing

The primary license for this repository is the Business Source License 1.1 (`BUSL-1.1`). See [`LICENSE`](./LICENSE).
Minus the following exceptions:

- [Interfaces](contracts/interfaces/) have a General Public License
- [Some libraries](contracts/parallelizer/libraries/LibHelpers.sol) have a General Public License

Each of these files states their license type.
