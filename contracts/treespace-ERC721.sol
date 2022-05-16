// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @custom:security-contact support@treespace.xyz
contract Treespace is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Treespace", "TREE") {}

    // tokenID => basispointsRoyalties
    mapping(uint => uint) public marketplaceRoyalties;

    // tokenID => creator
    mapping(uint => address) public creatorOfToken;

    function _baseURI() internal pure override returns (string memory) {
        return "ar://";
    }

    /*
    @title publicMint
    @dev allows anyone to mint an NFT to the contract
    @param URI the IPFS hash pointing to the metadata
    @param _royaltiesBasisPoints the Royalties to be set
    */
    function publicMint(string memory _URI, uint _royaltiesBasisPoints) public {
        uint256 tokenId = _tokenIdCounter.current();

        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _URI);

        // set the royalties
        _setMarketplaceRoyalties(_royaltiesBasisPoints, tokenId);

        // remember the creator
        creatorOfToken[tokenId] = msg.sender;
    }

    /* 
    @dev get the royalties for a specific NFT - for the marketplace contracts
    @parma _tokenID used to get the basispoint
    @returns uint the basispoints
    */
    function getRoyaltiesOfToken(uint _tokenID) public view returns (uint) {
        return(marketplaceRoyalties[_tokenID]);
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /* 
    @dev set the royalties for the NFT
    @param _basispoints max. 10_000
    @param _tokenID 
    */
    function _setMarketplaceRoyalties(uint _basispoints, uint _tokenID) internal {
        require(_basispoints <= 3000, "ERC721::Royalities must be below or equal to 30 percent!");

        // set the royalties for the NFT
        marketplaceRoyalties[_tokenID] = _basispoints;
    }

    /* 
    @dev 
    * change the royalties of an NFT. 
    * can only be lowered
    * no less than zero

    @check the NFT was createde by msg.sender, also makes sure the token exists
    @check basispoints cannot be zero
    @check _newBasisPoints must be lower than _currentBasisPoints
    @param _tokenID the ID for the token
    @param _newBasisPoints the new royalties
    */
    function changeMarketplaceRoyalties(uint _tokenID, uint _newBasisPoints) public {
        require(msg.sender == creatorOfToken[_tokenID], "ERC721:Only creator can change Royalties.");
        require(marketplaceRoyalties[_tokenID] != 0, "ERC721:Royalties already at 0!");
        require(marketplaceRoyalties[_tokenID] > _newBasisPoints, "ERC721:Royalties can only be lowered!");

        marketplaceRoyalties[_tokenID] = _newBasisPoints;
    }

    /* 
     @dev returns the creator of an NFT for the marketplace contract
     @param _tokenID 
    */
    function getCreatorOfToken(uint _tokenID) public view returns (address){
        return(creatorOfToken[_tokenID]);
    }
}
