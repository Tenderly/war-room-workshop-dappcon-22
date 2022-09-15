// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";
import "./OwnableUpgradeable.sol";

// Note to participants:
// Upgrade this contract to deploy and execute your exploit!
// Be careful not to disable upgradability if you intent to upgrade again.
contract Account is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    bytes32 internal constant ACCOUNT_IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor() {
        __Ownable_init();
    }

    function initialize() public initializer {
        __Ownable_init();
    }

    function _authorizeUpgrade(address) internal view override {
        require(
            msg.sender == owner() ||
                Account(
                    StorageSlot
                        .getAddressSlot(ACCOUNT_IMPLEMENTATION_SLOT)
                        .value
                ).owner() ==
                address(0),
            "Upgrade denied!"
        );
    }
}
