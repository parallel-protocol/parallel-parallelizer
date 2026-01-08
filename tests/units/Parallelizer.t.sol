// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

import { ITokenP } from "contracts/interfaces/ITokenP.sol";
import { AggregatorV3Interface } from "contracts/interfaces/external/chainlink/AggregatorV3Interface.sol";

import { MockAccessControlManager } from "tests/mock/MockAccessControlManager.sol";
import { MockChainlinkOracle } from "tests/mock/MockChainlinkOracle.sol";
import { MockTokenPermit } from "tests/mock/MockTokenPermit.sol";
import { MockMorphoOracle } from "tests/mock/MockMorphoOracle.sol";
import { IGetters } from "contracts/interfaces/IGetters.sol";

import { Test } from "contracts/parallelizer/configs/Test.sol";
import { LibGetters } from "contracts/parallelizer/libraries/LibGetters.sol";
import "contracts/parallelizer/Storage.sol";
import "contracts/utils/Constants.sol";
import "contracts/utils/Errors.sol";

import { Fixture } from "../Fixture.sol";

contract TestParallelizer is Fixture {
  function test_FacetsHaveCorrectSelectors() public {
    for (uint256 i = 0; i < facetAddressList.length; ++i) {
      bytes4[] memory fromLoupeFacet = parallelizer.facetFunctionSelectors(facetAddressList[i]);
      bytes4[] memory fromGenSelectors = _generateSelectors(facetNames[i]);
      assertTrue(sameMembers(fromLoupeFacet, fromGenSelectors));
    }
  }

  function test_SelectorsAssociatedWithCorrectFacet() public {
    for (uint256 i = 0; i < facetAddressList.length; ++i) {
      bytes4[] memory fromGenSelectors = _generateSelectors(facetNames[i]);
      for (uint256 j = 0; j < fromGenSelectors.length; j++) {
        assertEq(facetAddressList[i], parallelizer.facetAddress(fromGenSelectors[j]));
      }
    }
  }

  function test_InterfaceCorrectlyImplemented() public {
    bytes4[] memory selectors = _generateSelectors("IParallelizer");
    for (uint256 i = 0; i < selectors.length; ++i) {
      assertEq(parallelizer.isValidSelector(selectors[i]), true);
    }
  }

  // Checks that all implemented selectors are in the interface
  function test_OnlyInterfaceIsImplemented() public {
    bytes4[] memory interfaceSelectors = _generateSelectors("IParallelizer");

    Facet[] memory facets = parallelizer.facets();

    for (uint256 i; i < facetNames.length; ++i) {
      for (uint256 j; j < facets[i].functionSelectors.length; ++j) {
        bool found = false;
        for (uint256 k; k < interfaceSelectors.length; ++k) {
          if (facets[i].functionSelectors[j] == interfaceSelectors[k]) {
            found = true;
            break;
          }
        }
        assert(found);
      }
    }
  }

  function test_QuoteInScenario() public {
    uint256 quote = (parallelizer.quoteIn(BASE_6, address(eurA), address(tokenP)));
    assertEq(quote, BASE_27 / (BASE_9 + BASE_9 / 99));
  }

  function test_SimpleSwapInScenario() public {
    deal(address(eurA), alice, BASE_6);

    startHoax(alice);
    eurA.approve(address(parallelizer), BASE_6);
    parallelizer.swapExactInput(BASE_6, 0, address(eurA), address(tokenP), alice, block.timestamp + 1 hours);

    assertEq(tokenP.balanceOf(alice), BASE_27 / (BASE_9 + BASE_9 / 99));
  }

  function test_QuoteCollateralRatio() public {
    parallelizer.getCollateralRatio();
    assertEq(uint256(0), uint256(0));
  }

  function test_QuoteCollateralRatioDirectCall() public {
    LibGetters.getCollateralRatio();
    assertEq(uint256(0), uint256(0));
  }

  ///---------------------------------
  /// Test ProcessSurplus
  ///---------------------------------

  function test_ProcessSurplus_Success()
    public
    swapSomeCollateralToTokenPAndUpdateOracleToMorphoOracle
    updateSlippageToleranceTo1e7
  {
    vm.startPrank(governor);
    (uint256 collateralSurplus, uint256 stableSurplus) = parallelizer.getCollateralSurplus(address(eurA));
    uint256 amountOut = parallelizer.quoteIn(collateralSurplus, address(eurA), address(tokenP));

    parallelizer.processSurplus(address(eurA));
    assertEq(tokenP.balanceOf(address(parallelizer)), amountOut);
  }

  function test_ProcessSurplus_RevertWhen_AmountOutIsTooSmall()
    public
    swapSomeCollateralToTokenPAndUpdateOracleToMorphoOracle
  {
    vm.startPrank(governor);
    vm.expectRevert(TooSmallAmountOut.selector);
    parallelizer.processSurplus(address(eurA));
  }

  function test_ProcessSurplus_RevertWhen_NoSurplus() public {
    vm.startPrank(governor);
    vm.expectRevert(ZeroAmount.selector);
    parallelizer.processSurplus(address(eurA));
  }

  ///---------------------------------
  /// Test Release
  ///---------------------------------

  function test_Release_Surplus_Success() public addReleasePayees setSomeSurplus updateSlippageToleranceTo1e7 {
    vm.startPrank(governor);
    uint256 surplus = tokenP.balanceOf(address(parallelizer));
    (address[] memory payees, uint256[] memory amounts) = parallelizer.release();
    assertEq(payees.length, 2);
    assertEq(payees[0], address(0));
    assertEq(payees[1], address(treasury));
    assertEq(amounts[0], surplus * 1 ether / 10 ether);
    assertEq(amounts[1], surplus * 9 ether / 10 ether);
    assertEq(tokenP.balanceOf(address(treasury)), surplus * 9 ether / 10 ether);
    assertEq(tokenP.balanceOf(address(parallelizer)), 0);
  }

  function test_Release_Surplus_RevertWhen_NoIncome() public addReleasePayees {
    vm.startPrank(governor);
    vm.expectRevert(ZeroAmount.selector);
    parallelizer.release();
  }

  ///---------------------------------
  /// Helpers
  ///---------------------------------

  modifier swapSomeCollateralToTokenPAndUpdateOracleToMorphoOracle() {
    _swapSomeCollateralToTokenPAndUpdatOracleToMorphoOracle();
    _;
  }

  modifier updateOracleToMorphoOracle(uint256 newPrice) {
    MockMorphoOracle morphoOracle = new MockMorphoOracle(newPrice);
    OracleReadType readType = OracleReadType.MORPHO_ORACLE;
    OracleReadType targetType = OracleReadType.MAX;
    bytes memory readData = abi.encode(address(morphoOracle), 1);
    bytes memory targetData = abi.encode(newPrice);

    parallelizer.setOracle(
      address(eurA), abi.encode(readType, targetType, readData, targetData, abi.encode(uint128(0), uint128(0)))
    );

    _;
  }

  modifier updateSlippageToleranceTo1e7() {
    vm.startPrank(governor);
    parallelizer.updateSlippageTolerance(address(eurA), 1e7);
    _;
  }

  modifier setSomeSurplus() {
    _swapSomeCollateralToTokenPAndUpdatOracleToMorphoOracle();
    vm.startPrank(governor);
    parallelizer.updateSlippageTolerance(address(eurA), 1e7);
    parallelizer.processSurplus(address(eurA));
    _;
  }

  modifier addReleasePayees() {
    _updateReleasePayees();
    _;
  }

  function _swapSomeCollateralToTokenPAndUpdatOracleToMorphoOracle() internal {
    vm.startPrank(guardian);
    // Update fees to 0
    uint64[] memory xMintFee = new uint64[](1);
    xMintFee[0] = uint64(0);
    int64[] memory yMintFee = new int64[](1);
    yMintFee[0] = int64(0);
    parallelizer.setFees(address(eurA), xMintFee, yMintFee, true);

    vm.startPrank(governor);
    // Swap some amount of eurA to tokenP
    uint256 amount = 10 * BASE_6;
    deal(address(eurA), address(governor), amount);
    eurA.approve(address(parallelizer), amount);
    parallelizer.swapExactInput(amount, 0, address(eurA), address(tokenP), governor, block.timestamp + 1 hours);

    // Update oracle to MorphoOracle and set price to 1.08$
    uint256 baseValue = 1.08e18; // 1.08$
    uint256 normalizationFactor = 0;
    MockMorphoOracle morphoOracle = new MockMorphoOracle(baseValue);
    OracleReadType readType = OracleReadType.MORPHO_ORACLE;
    OracleReadType targetType = OracleReadType.MAX;
    bytes memory readData = abi.encode(address(morphoOracle), 10 ** normalizationFactor);
    bytes memory targetData = abi.encode(baseValue);

    parallelizer.setOracle(
      address(eurA), abi.encode(readType, targetType, readData, targetData, abi.encode(uint128(0), uint128(0)))
    );
  }

  function _updateReleasePayees() internal {
    vm.startPrank(governor);
    address[] memory payees = new address[](2);
    payees[0] = address(0);
    payees[1] = address(treasury);
    uint256[] memory shares = new uint256[](2);
    shares[0] = 1 ether;
    shares[1] = 9 ether;
    parallelizer.updatePayees(payees, shares);
  }
}
