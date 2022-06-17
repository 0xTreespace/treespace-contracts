// SPDX-License-Identifier: MIT
pragma solidity ^8.0.4;

// @title Marketplace Config
// this contract stores the logic used by 
// markeptlace contracts to get data about 
// the Royalties and the creator of a token

contract MarketplaceConfig {
    
    event changedMarketplaceRoyalties(uint indexed _tokenID, uint _newBasisPoints);

    // store the creator of a token
    mapping(uint => address) public creatorOfToken;

    // get created tokens by an address
    mapping(address => uint[]) public createdTokensByAddress; 

    // get the royalties of a NFT
    mapping(uint => uint) public marketplaceRoyalties;

    // get the Receiver of Royalties (address)
    mapping(uint => address) public royaltieReceiver;
    
    // max royalties that can be set - default to 1000 or 10%
    uint _maxRoyalties = 1000;


    function getCreatedTokensByAddress(address _target) public view returns(uint[] memory) {
        return createdTokensByAddress[_target];
    }

    /* 
    @dev set the royalties for the NFT and the receiving address
    @param _basispoints max. 10_000
    @param _tokenID 
    */
    function _setMarketplaceRoyalties(uint _basispoints, uint _tokenID, address _royaltieReceiver) internal {
        require(_basispoints <= _maxRoyalties, "ERC721::_setMarketplaceRoyalties:Royalities must be below or equal to 30 percent!");
        
        // set the royalties for the NFT
        marketplaceRoyalties[_tokenID] = _basispoints;

        // set receiver
        royaltieReceiver[_tokenID] = _royaltieReceiver;
    }


    /* 
    @dev 
    * change the royalties of an NFT. 
    * can only be lowered
    * no less than zero

    @check the NFT was created by msg.sender, also makes sure the token exists (msg.sender != address(0x0))
    @check basispoints cannot be zero
    @check _newBasisPoints must be lower than _currentBasisPoints

    @param _tokenID the ID for the token
    @param _newBasisPoints the new royalties
    */
    function changeMarketplaceRoyalties(uint _tokenID, uint _newBasisPoints) public {
        require(msg.sender == creatorOfToken[_tokenID], "ERC721::changeMarketplaceRoyalties:Only creator can change Royalties.");
        require(marketplaceRoyalties[_tokenID] != 0, "ERC721::changeMarketplaceRoyalties:Royalties already at 0!");
        require(marketplaceRoyalties[_tokenID] > _newBasisPoints, "ERC721::changeMarketplaceRoyalties:Royalties can only be lowered!");

        // set royalties
        marketplaceRoyalties[_tokenID] = _newBasisPoints;

        emit changedMarketplaceRoyalties(_tokenID, _newBasisPoints);
    }

     /* 
    ARTIST FUNCTION
    ---------------
    @dev change the receiving address of the royalties
    
    @check the NFT was created by msg.sender, also makes sure the token exists (msg.sender != address(0x0))
    @check new address cannot be zero
    */
    function changeRoyaltieReceivingAddress(uint _tokenID, address payable _newReceivingAddress) public {
        require(msg.sender == creatorOfToken[_tokenID], "ERC721::changeRoyaltieReceivingAddress:Only creator can change receiving address.");
        require(_newReceivingAddress != address(0x0), "ERC721::changeRoyaltieReceivingAddress:Address must not be null.");
        
    }

    /*
    VIEW FUNCTIONS 
    ----------------------
    These functions are used by other contracts to get data on certain
    parameters such as the creator of a token or the royalties.
    */

    function getCreatorOfToken(uint _tokenID) public view returns (address){
        return(creatorOfToken[_tokenID]);
    }

    function getRoyaltiesOfToken(uint _tokenID) public view returns (uint) {
        return(marketplaceRoyalties[_tokenID]);
    }
    
    function getRoyaltieReceiver(uint _tokenID) public view returns (address) {
        return(royaltieReceiver[_tokenID]);
    }

}