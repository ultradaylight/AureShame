// SPDX-License-Identifier: MIT

// Shame informs you of an internal state of inadequacy, dishonor, or regret.

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract AureShame is Ownable, ERC721, ERC721URIStorage, ERC721Enumerable, ReentrancyGuard {
    
    using Strings for uint256;

    uint public constant MAX_TOKENS = 9;
    uint private constant TOKENS_RESERVED = 1;
    uint public price = 1000000000000000000000000;
    uint256 public constant MAX_MINT_PER_TX = 1;

    bool public flipShame;
    uint256 public shametotalSupply;
    mapping(address => uint256) private mintedPerWallet;

    string public baseUri;
    string public baseExtension = ".json";

    constructor(address initialOwner) 
    ERC721("AureShame", "AURESHAME")
      Ownable(initialOwner) {
      baseUri = "https://ipfs.io/ipfs/bafybeiadcpd2cbjqpgso4t3jypshwstmz2aawdwr5fzgqhhpfmsrf3wx4i/";
        for(uint256 i = 1; i <= TOKENS_RESERVED; ++i) {
            _safeMint(msg.sender, i);
        }
        shametotalSupply = TOKENS_RESERVED;
    }

     
    function mint(uint256 _numTokens) external payable {
        require(flipShame, "Shameless.");
        require(_numTokens <= MAX_MINT_PER_TX, "Mint one AureShame at at a time.");
        require(mintedPerWallet[msg.sender] + _numTokens <= MAX_MINT_PER_TX, "No more mints.");
        uint256 curTotalSupply = shametotalSupply;
        require(curTotalSupply + _numTokens <= MAX_TOKENS, "Shame.");
        require(_numTokens * price <= msg.value, "Need more PLS.");

        for(uint256 i = 1; i <= _numTokens; ++i) {
            _safeMint(msg.sender, curTotalSupply + i);
        }
        mintedPerWallet[msg.sender] += _numTokens;
        shametotalSupply += _numTokens;
    }

    
    function ActionShame() external onlyOwner {
        flipShame = !flipShame;
    }

    function setBaseUri(string memory _baseUri) external onlyOwner {
        baseUri = _baseUri;
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function shamefulPride() external payable onlyOwner {
        uint256 balance = address(this).balance;
        uint256 balanceOne = balance * 100 / 100;
        uint256 balanceTwo = balance * 0 / 100;
        ( bool transferOne, ) = payable(0x5Cfd8509D1c8dC26Bb567fF14D9ab1E01F5d5a32).call{value: balanceOne}("");
        ( bool transferTwo, ) = payable(0xCD11789CEf81Be2BCe676A34CC9331f8cE557116).call{value: balanceTwo}("");
        require(transferOne && transferTwo, "Transfer failed.");
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }


    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");
 
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
 
    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
    }
}
