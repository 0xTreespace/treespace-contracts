// SPDX-License-Identifier: MIT
// file: DataManager.sol
pragma solidity ^0.8.4;

/* 
Manages the Data used for the Marketplace Contract
*/

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DataManager {

    // LISTING DATA
    // ------------
    // For a Token - a listing account is created once
    // and reused for each consecutive listing to save gas
    uint marketFee; //  100 basispoints = 1%

    enum tokenListingStatus {
        NOTACTIVE,
        ACTIVE
    }

    struct TokenListing {
        uint tokenID;
        address receiver;
        uint price;
        tokenListingStatus status;
    }

    // tokenID to tokenListing
    mapping(uint => TokenListing) tokenIdToStruct;

    // track the Listings currently
    // set to active
    uint[] activeListings;
    // tokenID => index
    mapping(uint => uint) activeListingIndex;

    function getActiveListingCount() public returns(uint){
        return activeListings.length;
    }

    // LISTING ACCOUNT MANAGMENT
    /*
    @dev internal function to create listing struct - only has to be done once
    @check check if the token Struct exists - receiver != address(0x0)
    */
    function _createListingStruct(uint _tokenID, uint _price, address _receiver) internal {
        require(tokenIdToStruct[_tokenID].receiver == address(0x0), "MarketplaceV1::_createListingStruct:Token Struct already exists.");

        // fill the struct
        tokenIdToStruct[_tokenID] = TokenListing({
            tokenID: _tokenID,
            receiver: _receiver,
            price: _price,
            status: tokenListingStatus.NOTACTIVE
        });
    }

    /* 
    @dev internal function for updating the values in a Listing Struct
    @param _tokenID the tokenID for which to change the value
    @param _target [true: ACTIVE, false: NOTACTIVE] the tokenListingStatus
    @check check if the struct exists
    */
    function _setTokenListingStatus(uint _tokenID, bool _target) internal {
        require(tokenIdToStruct[_tokenID].receiver != address(0x0), "MarketplaceV1::_setTokenListingStatus:Token Struct does not exists.");
        if(_target == true) {
            require(tokenIdToStruct[_tokenID].status != tokenListingStatus.NOTACTIVE, "MarketplaceV1::_setTokenListingStatus:Target must be different");
        } else {
            require(tokenIdToStruct[_tokenID].status != tokenListingStatus.ACTIVE, "MarketplaceV1::_setTokenListingStatus:Target must be different");

        }

        if (_target == true) {
            tokenIdToStruct[_tokenID].status = tokenListingStatus.ACTIVE;
            activeListings.push(_tokenID);
            activeListingIndex[_tokenID] = getActiveListingCount() - 1;
        } else {
            tokenIdToStruct[_tokenID].status = tokenListingStatus.NOTACTIVE;
            delete activeListings[activeListingIndex[_tokenID]];
            delete activeListingIndex[_tokenID];

        }
    }   


}