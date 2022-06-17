// SPDX-License-Identifier: MIT
// file: MarketplaceV1
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/access/Ownable.sol";
import "./DataManager.sol";

import "../../Interface/tIERC721.sol";

/* 
@title MarketplaceV1
@dev basic marketplace where users can list NFTs for a fixed Price
Does not support bidding
Does not support reserve Price Auctions
*/

contract MarketplaceV1 is DataManager {
    
    address nftTokenAddress;
    IERC721 itemToken;
    
    constructor (address _itemTokenAddress)
        public
    {
        itemToken = IERC721(_itemTokenAddress);
        nftTokenAddress = _itemTokenAddress;
        marketFee = 100;
    }

    event TokenListed(uint, address, uint);

    /* 
    Listing Function
    --------------
    @dev Allows a user to put up an NFT as a listing
    @param _tokenID 
    @param _price 
    @check if the price is above zero
    */

    function createListing(uint _tokenID, uint _price) {
        require(_price > 0, "MARKETPLACEV1::createListing:Price must be above zero");

        itemToken.transferFrom(msg.sender, address(this), _tokenID);

        _createListingStruct(_tokenID, _price, msg.sender);
        _setTokenListingStatus(_tokenID, true);

        emit TokenListed(_tokenID, msg.sender, _price);
    }

    /* 
    Buying Function
    ---------------
    @dev call this function to buy a listed NFT
    @param _tokenID the token to buy
    */

    function buyFixedPriceListing(uint _tokenID) {
        require(tokenIdToStruct[_tokenID]["price"] == msg.value, "MARKETPLACEV1::buyFixedPriceListing:Value Sent does not match");
        require(tokenIdToStruct[_tokenID]["receiver"] == tokenListingStatus.ACTIVE, "MARKETPLACEV1::buyFixedPriceListing:Token is not listed");
        
        // transfer the token to the user
        itemToken.transferFrom(address(this), msg.sender, _tokenID);

        // distribute the msg.value to the royaltieReceiver
        address payable royaltieReceiver = itemToken.getRoyaltieReceiver(_tokenID);
        address payable royalties = itemToken.getRoyaltiesOfToken(_tokenID);

        
    }   

}
