// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.28;

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

import { ITokenP } from "contracts/interfaces/ITokenP.sol";
import { AggregatorV3Interface } from "contracts/interfaces/external/chainlink/AggregatorV3Interface.sol";

import { MockAccessControlManager } from "tests/mock/MockAccessControlManager.sol";
import { MockChainlinkOracle } from "tests/mock/MockChainlinkOracle.sol";
import { MockTokenPermit } from "tests/mock/MockTokenPermit.sol";

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
}
