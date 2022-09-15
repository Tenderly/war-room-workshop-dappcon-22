// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface ISimpleNFT {
    function addLike(uint256 id) external;

    function removeLike() external;
}
