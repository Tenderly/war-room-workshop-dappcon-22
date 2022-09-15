// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./IBorrower.sol";

contract Lender is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    // Mapping of balances of each user
    mapping(address => uint256) public balances;

    //Max amount a user can deposit and hold needs to be set
    uint256 public maxWalletAmount;
    bool internal locked;

    //Interface
    IERC20 public immutable simpleToken;
    IERC721 public immutable simpleNFT;

    // Only certain proxies are allowed to interact with the contract
    mapping(address => bool) public authorizedProxies;

    event lenderContractDeployed(
        address token,
        address nftAddress,
        uint256 maxAmount
    );
    event lenderProxyWhitelisted(address indexed proxy);
    event lenderProxyBlacklisted(address indexed proxy);

    /**
     * @dev Initializer for Lender
     * @param tokenAddress address of the token contract that will be used for flash loans
     * @param nftAddress address of the nft contract used to access the contract
     * @param maxAmount max amount of token a user can hold
     */

    constructor(
        address tokenAddress,
        address nftAddress,
        uint256 maxAmount
    ) {
        require(tokenAddress != address(0), "Token address cannot be zero");
        require(nftAddress != address(0), "Token address cannot be zero");
        simpleToken = IERC20(tokenAddress);
        simpleNFT = IERC721(nftAddress);
        maxWalletAmount = maxAmount;
        emit lenderContractDeployed(
            address(simpleToken),
            address(simpleNFT),
            maxWalletAmount
        );
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    /**
     * @dev Authorizes access for a specific address
     * @param proxy address of a deployed proxy
     */
    function whitelistProxy(address proxy) public onlyOwner noReentrant {
        authorizedProxies[proxy] = true;
        emit lenderProxyWhitelisted(proxy);
    }

    /**
     * @dev Removes access for a specific address
     * @param proxy address of a deployed proxy
     */
    function blacklistProxy(address proxy) public onlyOwner noReentrant {
        authorizedProxies[proxy] = false;
        emit lenderProxyBlacklisted(proxy);
    }

    /**
     * @dev Deposit ERC20 token into the contract
     * @param amount of ERC20 tokens to deposit
     * @param tokenId id of the specific token owned in the required collection
     */

    function depositFunds(uint256 amount, uint256 tokenId)
        external
        noReentrant
    {
        // Only authorised proxies can access the function
        require(authorizedProxies[msg.sender], "Not part of the CTF");
        // Only NFT owners can access the function
        require(
            simpleNFT.ownerOf(tokenId) == msg.sender,
            "You need to have the NFT"
        );

        IERC20(simpleToken).safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender] = (
            balances[msg.sender] + amount <= maxWalletAmount
                ? balances[msg.sender] + amount
                : maxWalletAmount
        );
    }

    /**
     * @dev Return funds back to the user
     * @param amount of ERC20 tokens to withdraw
     * @param tokenId id of the specific token owned in the required collection
     */

    function releaseFunds(uint256 amount, uint256 tokenId)
        external
        nonReentrant
    {
        // Only authorised proxies can access the function
        require(authorizedProxies[msg.sender], "Not part of the CTF");
        // Only NFT owners can access the function
        require(
            simpleNFT.ownerOf(tokenId) == msg.sender,
            "You need to have the NFT"
        );
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        simpleToken.safeTransfer(msg.sender, amount);
    }

    /**
     * @dev Flashloan feature
     * @param amount of ERC20 tokens to borrow
     * @param tokenId id of the specific token owned in the required collection
     */
    function executeFlashloan(uint256 amount, uint256 tokenId)
        external
        nonReentrant
    {
        require(amount > 0, "Must borrow more than 0 tokens");
        // Only NFT owners can access the function
        require(
            simpleNFT.ownerOf(tokenId) == msg.sender,
            "You need to have the NFT"
        );
        require(
            amount <= simpleToken.balanceOf(address(this)),
            "Pool liquidity exceeded"
        );

        // Only authorised proxies can access the function
        require(authorizedProxies[msg.sender], "Not part of the CTF");

        uint256 balanceBefore = simpleToken.balanceOf(address(this));
        // send the funds
        simpleToken.safeTransfer(msg.sender, amount);
        // hand control over to the borrower
        IBorrower(msg.sender).onTokenReceive(amount);
        // verify that loan has been paid back
        uint256 balanceAfter = simpleToken.balanceOf(address(this));

        require(balanceAfter >= balanceBefore, "failed payback");
    }
}
