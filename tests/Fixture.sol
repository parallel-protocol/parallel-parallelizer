// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.19;

import { console } from "@forge-std/console.sol";

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
import { ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import { Constants,ContractType } from "@helpers/Constants.sol";

import { IAccessControlManager } from "interfaces/IAccessControlManager.sol";
import { IAgToken } from "interfaces/IAgToken.sol";
import { IManager } from "interfaces/IManager.sol";
import { AggregatorV3Interface } from "interfaces/external/chainlink/AggregatorV3Interface.sol";

import {CHAIN_SOURCE} from "scripts/helpers/Constants.s.sol";

import { MockAccessControlManager } from "./mock/MockAccessControlManager.sol";
import { MockChainlinkOracle } from "./mock/MockChainlinkOracle.sol";
import { MockTokenPermit } from "./mock/MockTokenPermit.sol";

import { CollateralSetup, Test } from "contracts/transmuter/configs/Test.sol";
import "contracts/utils/Constants.sol";
import "contracts/utils/Errors.sol";
import { ITransmuter, Transmuter } from "./utils/Transmuter.sol";



contract Fixture is Transmuter {
    IAccessControlManager public accessControlManager;
    ProxyAdmin public proxyAdmin;
    IAgToken public agToken;

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
    address public angle;
    address public governor;

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

        vm.label(governor, "Governor");
        vm.label(governor, "Governor");
        vm.label(guardian, "Guardian");
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(charlie, "Charlie");
        vm.label(dylan, "Dylan");
        vm.label(sweeper, "Sweeper");

        // Access Control
        accessControlManager = IAccessControlManager(address(new MockAccessControlManager()));
        MockAccessControlManager(address(accessControlManager)).toggleGovernor(governor);
        MockAccessControlManager(address(accessControlManager)).toggleGuardian(guardian);
        proxyAdmin = new ProxyAdmin(governor);

        // agToken
        agToken = IAgToken(address(new MockTokenPermit("agEUR", "agEUR", 18)));

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

        deployTransmuter(
            config,
            abi.encodeWithSelector(
                Test.initialize.selector,
                accessControlManager,
                agToken,
                CollateralSetup(address(eurA), address(oracleA)),
                CollateralSetup(address(eurB), address(oracleB)),
                CollateralSetup(address(eurY), address(oracleY))
            )
        );

        vm.label(address(agToken), "AgToken");
        vm.label(address(transmuter), "Transmuter");
        vm.label(address(eurA), "eurA");
        vm.label(address(eurB), "eurB");
        vm.label(address(eurY), "eurY");
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
    ) internal virtual {
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

    function _mintExactOutput(
        address owner,
        address tokenIn,
        uint256 amountStable,
        uint256 estimatedAmountIn
    ) internal {
        vm.startPrank(owner);
        deal(tokenIn, owner, estimatedAmountIn);
        IERC20(tokenIn).approve(address(transmuter), type(uint256).max);
        transmuter.swapExactOutput(
            amountStable,
            estimatedAmountIn,
            tokenIn,
            address(agToken),
            owner,
            block.timestamp * 2
        );
        vm.stopPrank();
    }

    function _mintExactInput(address owner, address tokenIn, uint256 amountIn, uint256 estimatedStable) internal {
        vm.startPrank(owner);
        deal(tokenIn, owner, amountIn);
        IERC20(tokenIn).approve(address(transmuter), type(uint256).max);
        transmuter.swapExactInput(amountIn, estimatedStable, tokenIn, address(agToken), owner, block.timestamp * 2);
        vm.stopPrank();
    }
}
