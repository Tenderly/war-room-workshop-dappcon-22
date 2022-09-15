// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./FlagNFT.sol";

contract Flag is Ownable {
    address public token;
    address public lender;
    address public flag;
    uint256 public price;

    mapping(address => bool) public authorizedProxies;

    event flagContractDeployed(address token, address lender, address flag, uint256 price);
    event flagProxyWhitelisted(address indexed proxy);
    event flagCaptured(address indexed to);


    constructor(
        address tokenAddress,
        address lenderAddress,
        address flagAddress,
        uint256 nftPrice
    ) {
        token = tokenAddress;
        lender = lenderAddress;
        flag = flagAddress;
        price = nftPrice;
        emit flagContractDeployed(tokenAddress, lenderAddress, flagAddress, nftPrice);
    }

    /**
     * @dev Authorizes access for a specific address
     * @param proxy address of a deployed proxy
     */
    function whitelistProxy(address proxy) public onlyOwner {
        authorizedProxies[proxy] = true;
        emit flagProxyWhitelisted(proxy);
    }

    /**
     * @dev Finally capture the flag!
     */
    function capture() public {
        require(authorizedProxies[msg.sender], "Not part of the CTF");
        IERC20(token).transferFrom(msg.sender, lender, price);
        FlagNFT(flag).mint(msg.sender);
        authorizedProxies[msg.sender] = false;
        emit flagCaptured(msg.sender);
    }
}
