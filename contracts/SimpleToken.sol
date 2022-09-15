// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleToken is ERC20 {
    constructor(uint256 amount) ERC20("Quantstamp CTF", "CTF") {
        _mint(msg.sender, amount);
    }
}
