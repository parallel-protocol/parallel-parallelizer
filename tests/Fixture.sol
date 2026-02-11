// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.28;

import { console } from "@forge-std/console.sol";

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

import { Constants, ContractType } from "@helpers/Constants.sol";

import { ITokenP } from "contracts/interfaces/ITokenP.sol";
import { IManager } from "contracts/interfaces/IManager.sol";
import { AggregatorV3Interface } from "contracts/interfaces/external/chainlink/AggregatorV3Interface.sol";
import { SavingsNameable } from "contracts/savings/nameable/SavingsNameable.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { CHAIN_SOURCE } from "scripts/helpers/Constants.s.sol";

import { MockAccessControlManager } from "./mock/MockAccessControlManager.sol";
import { MockChainlinkOracle } from "./mock/MockChainlinkOracle.sol";
import { MockTokenPermit } from "./mock/MockTokenPermit.sol";

import { CollateralSetup, Test } from "contracts/parallelizer/configs/Test.sol";
import "contracts/utils/Constants.sol";
import "contracts/utils/Errors.sol";
import { IParallelizer } from "contracts/interfaces/IParallelizer.sol";
import { Parallelizer } from "./utils/Parallelizer.sol";
import { ConfigAccessManager } from "./utils/ConfigAccessManager.sol";
import { SavingsUtils } from "./utils/Savings.sol";
import { GenericRebalancerUtils } from "./utils/GenericRebalancerUtils.sol";

contract Fixture is Parallelizer, SavingsUtils, ConfigAccessManager, GenericRebalancerUtils {
  ITokenP public tokenP;

  IERC20 public eurA;
  AggregatorV3Interface public oracleA;
  IERC20 public eurB;
  AggregatorV3Interface public oracleB;
  IERC20 public eurY;
  AggregatorV3Interface public oracleY;

  address public config;

  // Percentage tolerance on test - 0.0001%
  uint256 internal constant _MAX_PERCENTAGE_DEVIATION = 1e12;
  uint256 internal constant _MAX_SUB_COLLATERALS = 10;

  address public guardian;
  address public governor;
  address public governorAndGuardian;

  address public alice;
  address public bob;
  address public charlie;
  address public dylan;
  address public sweeper;

  function setUp() public virtual {
    alice = vm.addr(1);
    bob = vm.addr(2);
    charlie = vm.addr(3);
    dylan = vm.addr(4);
    sweeper = address(uint160(uint256(keccak256(abi.encodePacked("sweeper")))));
    governor = address(uint160(uint256(keccak256(abi.encodePacked("governor")))));
    guardian = address(uint160(uint256(keccak256(abi.encodePacked("guardian")))));
    governorAndGuardian = address(uint160(uint256(keccak256(abi.encodePacked("governorAndGuardian")))));

    vm.label(governor, "Governor");
    vm.label(guardian, "Guardian");
    vm.label(governorAndGuardian, "GovernorAndGuardian");
    vm.label(alice, "Alice");
    vm.label(bob, "Bob");
    vm.label(charlie, "Charlie");
    vm.label(dylan, "Dylan");
    vm.label(sweeper, "Sweeper");

    deployAccessManager(governor, governor, guardian, governorAndGuardian);

    // tokenP
    tokenP = ITokenP(address(new MockTokenPermit("agEUR", "agEUR", 18)));

    // Collaterals
    eurA = IERC20(address(new MockTokenPermit("EUR_A", "EUR_A", 6)));
    vm.label(address(eurA), "eurA");
    oracleA = AggregatorV3Interface(address(new MockChainlinkOracle()));
    vm.label(address(oracleA), "oracleA");
    MockChainlinkOracle(address(oracleA)).setLatestAnswer(int256(BASE_8));

    eurB = IERC20(address(new MockTokenPermit("EUR_B", "EUR_B", 12)));
    vm.label(address(eurB), "eurB");
    oracleB = AggregatorV3Interface(address(new MockChainlinkOracle()));
    vm.label(address(oracleB), "oracleB");
    MockChainlinkOracle(address(oracleB)).setLatestAnswer(int256(BASE_8));

    eurY = IERC20(address(new MockTokenPermit("EUR_Y", "EUR_Y", 18)));
    vm.label(address(eurY), "eurY");
    oracleY = AggregatorV3Interface(address(new MockChainlinkOracle()));
    vm.label(address(oracleY), "oracleY");
    MockChainlinkOracle(address(oracleY)).setLatestAnswer(int256(BASE_8));

    // Config

    config = address(new Test());

    deployParallelizer(
      config,
      abi.encodeWithSelector(
        Test.initialize.selector,
        address(accessManager),
        tokenP,
        CollateralSetup(address(eurA), address(oracleA)),
        CollateralSetup(address(eurB), address(oracleB)),
        CollateralSetup(address(eurY), address(oracleY))
      )
    );

    vm.label(address(tokenP), "tokenP");
    vm.label(address(parallelizer), "Parallelizer");
    vm.label(address(eurA), "eurA");
    vm.label(address(eurB), "eurB");
    vm.label(address(eurY), "eurY");

    vm.startPrank(governor);
    accessManager.setTargetFunctionRole(address(parallelizer), getParallelizerGovernorSelectorAccess(), GOVERNOR_ROLE);
    accessManager.setTargetFunctionRole(address(parallelizer), getParallelizerGuardianSelectorAccess(), GUARDIAN_ROLE);
    vm.stopPrank();
  }

  /*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ASSERTIONS                                                    
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

  // Allow to have larger deviation for very small amounts
  function _assertApproxEqRelDecimalWithTolerance(
    uint256 a,
    uint256 b,
    uint256 condition,
    uint256 maxPercentDelta, // An 18 decimal fixed point number, where 1e18 == 100%
    uint256 decimals
  )
    internal
    virtual
  {
    for (uint256 tol = BASE_18 / maxPercentDelta; tol > 0; tol /= 10) {
      if (condition > tol) {
        assertApproxEqRelDecimal(a, b, tol == 0 ? BASE_18 : (BASE_18 / tol), decimals);
        break;
      }
    }
  }

  /*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ACTIONS                                                     
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

  function _mintExactOutput(address owner, address tokenIn, uint256 amountStable, uint256 estimatedAmountIn) internal {
    vm.startPrank(owner);
    deal(tokenIn, owner, estimatedAmountIn);
    IERC20(tokenIn).approve(address(parallelizer), type(uint256).max);
    parallelizer.swapExactOutput(amountStable, estimatedAmountIn, tokenIn, address(tokenP), owner, block.timestamp * 2);
    vm.stopPrank();
  }

  function _mintExactInput(address owner, address tokenIn, uint256 amountIn, uint256 estimatedStable) internal {
    vm.startPrank(owner);
    deal(tokenIn, owner, amountIn);
    IERC20(tokenIn).approve(address(parallelizer), type(uint256).max);
    parallelizer.swapExactInput(amountIn, estimatedStable, tokenIn, address(tokenP), owner, block.timestamp * 2);
    vm.stopPrank();
  }
}
