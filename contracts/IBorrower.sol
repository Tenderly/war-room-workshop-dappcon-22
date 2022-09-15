// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IBorrower {
    function onTokenReceive(uint256 amount) external;
}
