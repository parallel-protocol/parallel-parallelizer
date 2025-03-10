// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "./utils/Utils.s.sol";
import { console } from "forge-std/console.sol";
import { MultiBlockHarvester } from "contracts/helpers/MultiBlockHarvester.sol";
import { IAccessControlManager } from "contracts/utils/AccessControl.sol";
import { IAgToken } from "contracts/interfaces/IAgToken.sol";
import { ITransmuter } from "contracts/interfaces/ITransmuter.sol";
import "./Constants.s.sol";

contract DeployMultiBlockHarvester is Utils {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address deployer = vm.addr(deployerPrivateKey);
        console.log("Deployer address: ", deployer);
        uint96 maxSlippage = 0.3e7; // 0.3%
        address agToken = _chainToContract(CHAIN_SOURCE, ContractType.AgEUR);
        address transmuter = _chainToContract(CHAIN_SOURCE, ContractType.TransmuterAgEUR);
        IAccessControlManager accessControlManager = ITransmuter(transmuter).accessControlManager();

        MultiBlockHarvester harvester = new MultiBlockHarvester(
            maxSlippage,
            accessControlManager,
            IAgToken(agToken),
            ITransmuter(transmuter)
        );
        console.log("HarvesterVault deployed at: ", address(harvester));

        vm.stopBroadcast();
    }
}
