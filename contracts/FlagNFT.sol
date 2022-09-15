// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FlagNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Quantstamp CTF", "FLAG") {}

    /**
     * @dev Mints an NFT to the receiver address
     * @param receiver the recepient of the NFT
     */
    function mint(address receiver) external onlyOwner returns (uint256) {
        _tokenIds.increment();
        uint256 currId = _tokenIds.current();
        _mint(receiver, currId);
        return currId;
    }
}
