// SPDX-License-Identifier: MIT
// file: MarketplaceV1
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./DataManager.sol";

import "../../Interface/tIERC721.sol";

import "../../Interface/ITreespaceProvider.sol";

/*
@title MarketplaceV1
@dev basic marketplace where users can list NFTs for a fixed Price
Does not support bidding
Does not support reserve Price Auctions

This acts as a very simple marketplace to boostrap the project.
In further iterations, new features will be added.
*/

contract MarketplaceV1 is DataManager, Ownable {

    address nftTokenAddress;
    tIERC721 itemToken;
    ITreespaceProvider TreespaceProvider;

    constructor (
        address _itemTokenAddress,
        address _treespaceProviderAddress
        )
    {
        itemToken = tIERC721(_itemTokenAddress);
        nftTokenAddress = _itemTokenAddress;
        TreespaceProvider = ITreespaceProvider(_treespaceProviderAddress);
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

    function createListing(uint _tokenID, uint _price) public {
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

    function buyFixedPriceListing(uint _tokenID) public payable {
        require(tokenIdToStruct[_tokenID].price == msg.value, "MARKETPLACEV1::buyFixedPriceListing:Value Sent does not match");
        require(tokenIdToStruct[_tokenID].status == tokenListingStatus.ACTIVE, "MARKETPLACEV1::buyFixedPriceListing:Token is not listed");

        itemToken.transferFrom(address(this), msg.sender, _tokenID);

        // distribute the msg.value to the royaltieReceiver
        address payable royaltieReceiver = payable(itemToken.getRoyaltieReceiver(_tokenID));
        uint royalties = itemToken.getRoyaltiesOfToken(_tokenID);
        uint marketplaceFees = TreespaceProvider.getMarketplaceFees();

        // To do: find a better solution to this
        if(royalties == 0 && marketplaceFees == 0) {
            payable(tokenIdToStruct[_tokenID].receiver).transfer(msg.value);
        } else if(royalties != 0 && marketplaceFees == 0) {
            uint _royaltyAmount = msg.value * royalties / 10000;
            payable(tokenIdToStruct[_tokenID].receiver).transfer(msg.value - _royaltyAmount);
        } else if (royalties == 0 && marketplaceFees != 0){
            uint _feeAmount = msg.value * marketplaceFees / 10000;
            payable(tokenIdToStruct[_tokenID].receiver).transfer(msg.value - _feeAmount);
        } else {
            uint _feeAmount = msg.value * marketplaceFees / 10000;
            uint _royaltyAmount = msg.value * royalties / 10000;
            payable(tokenIdToStruct[_tokenID].receiver).transfer(msg.value - (_feeAmount + _royaltyAmount));
            royaltieReceiver.transfer(royalties);
        }
    }


}
