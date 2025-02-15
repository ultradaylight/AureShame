// SPDX-License-Identifier: MIT

// Shame informs you of an internal state of inadequacy, dishonor, or regret.

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AURESHAME is ERC721Enumerable, ERC721URIStorage, Ownable, ReentrancyGuard {
    uint256 public constant MAX_SUPPLY = 9;
    uint256 public constant MINT_PRICE = 1_000_000 * (10 ** 18); // 1M PLS assuming 18 decimals
    uint256 private _tokenIdCounter;
    string private baseUri = "https://ipfs.io/ipfs/bafybeic3sfsfzw6bnnd42c5qlfznlm5hweb3teuktzmbhciji6c2oxqxvy/";
    mapping(address => bool) private hasMinted;

    event BaseURIUpdated(string newBaseUri);
    event NFTMinted(address indexed recipient, uint256 tokenId);
    event Withdraw(address indexed owner, uint256 amount);
    event WithdrawTokens(address indexed owner, address token, uint256 amount);

    // Constructor with Ownable initial owner
    constructor() ERC721("AURESHAME", "ALIPS") Ownable(0xCD11789CEf81Be2BCe676A34CC9331f8cE557116) {
        _mintNFT(msg.sender, "1"); // Transfer one NFT to contract creator
        hasMinted[msg.sender] = true;
        _tokenIdCounter = 1; // Start counting from 1 since creator gets the first NFT
    }

    function setBaseURI(string memory newBaseUri) external onlyOwner {
        baseUri = newBaseUri;
        emit BaseURIUpdated(newBaseUri);
    }

    function mint(string memory tokenId) external payable nonReentrant {
        require(_tokenIdCounter < MAX_SUPPLY, "All NFTs have been minted");
        require(msg.value >= MINT_PRICE, "Insufficient payment");
        require(!hasMinted[msg.sender], "You can only mint one NFT");
        
        hasMinted[msg.sender] = true;
        _mintNFT(msg.sender, tokenId);
    }

    function _mintNFT(address recipient, string memory tokenId) private {
        require(_tokenIdCounter < MAX_SUPPLY, "All NFTs have been minted");
        _safeMint(recipient, _tokenIdCounter);
        _setTokenURI(_tokenIdCounter, tokenId);
        emit NFTMinted(recipient, _tokenIdCounter);
        _tokenIdCounter++;
    }

    function withdraw() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "No PLS to withdraw");
        payable(owner()).transfer(balance);
        emit Withdraw(owner(), balance);
    }

    function withdrawTokens(address tokenAddress) external onlyOwner nonReentrant {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        token.transfer(owner(), balance);
        emit WithdrawTokens(owner(), tokenAddress, balance);
    }

    // Override supportsInterface to resolve conflicts
    function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // Override the conflicting functions due to ERC721 and ERC721Enumerable
    function _increaseBalance(address account, uint128 value) internal virtual override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function _update(address to, uint256 tokenId, address auth) internal virtual override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return string(abi.encodePacked(baseUri, Strings.toString(tokenId), ".json"));
    }
}
