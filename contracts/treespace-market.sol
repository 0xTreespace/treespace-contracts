// SPDX-License-Identifier: MIT
// file: treespace_market.sol
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract treespaceMarket {

    IERC721 itemToken;
    
    constructor (address _itemTokenAddress)
        public
    {
        itemToken = IERC721(_itemTokenAddress);
        nftTokenAddress = _itemTokenAddress;
        listingCounter = 0;
        auctionCounter = 0;
        fee = 100;
    }

    uint fee; //  100 basispoints = 1%
    address nftTokenAddress;

    /* 
    To do:
    functions
        x - listNFT
            x -- as auction
            x -- as fixed price listing
        - withdraw listing
            -- withdraw fixedPricedListing
            -- cancel reservePriceAuction
        x - buy fixedPricedListing // tested
        x - bid on NFT (bid >= reserve price)
         - settle Auction
        x - withdraw expired Bid on NFT ----> the bid is automatically sent back
        x - add royalties
            x -- percentage set by user
            x -- embed in the ERC721 contract
                x --- set on creation
    */

    // the identifier to match auctions and fixed price listings 
    uint public listingCounter;
    uint public auctionCounter;

    // tracking the Status of listings
    enum fixedPriceListingStatus { 
        OPEN, 
        EXECUTED, 
        CANCELLED 
    } 
    enum reservePriceAuctionStatus { 
        NOTSTARTED,
        OPEN, 
        EXECUTED, 
        CANCELLED 
    } 

    // defines a standard fixed priced listing
    struct FixedPriceListing {
        address payable poster;
        uint256 tokenID;
        uint256 price;
        fixedPriceListingStatus status; // Open, Executed, Cancelled    
    }

    // defines the auction
    // has the same ID as the Trade struct
    struct Auction {
        address poster;
        uint tokenID;
        uint reservePrice;
        address highestBidder;
        uint highestBid;
    	uint timePeriod; // the amount of time the auction is live
        reservePriceAuctionStatus status; // Open, Executed, Cancelled    
        uint steps; // in wei

    }

    // auctionID => timestamp
    mapping(uint => uint) public auctionStart;

    mapping(uint => FixedPriceListing) public listings;
    mapping(uint => Auction) public auctions;

    // tokenID => listingID
    // for finding the listing of specific tokens
    // making it more searchable
    mapping(uint => uint) public ListingIdByTokenId;
    mapping(uint => uint) public AuctionIdByTokenId;

    /*
    @name createFixedPriceListing
    @dev lists an NFT at a fixed price
    @param _tokenID The ID of the erc721 token to list
    @param _price the price in wei
    */
    
    function createFixedPriceListing(uint _tokenID, uint _price) public {

        // transfer the NFT to the smart contract
        // acts as a check that the NFT exists
        itemToken.transferFrom(msg.sender, address(this), _tokenID);

        // create the trade order
        listings[listingCounter] = FixedPriceListing({
            poster: payable(msg.sender),
            tokenID: _tokenID,
            price: _price,
            status: fixedPriceListingStatus.OPEN
        
        });

        // map the listing ID to the tokenID
        ListingIdByTokenId[_tokenID] = listingCounter;

        listingCounter++; 
    }   

    /* 
    @name createReservePriceAuction
    @dev creates a reserve price auction
    @param _tokenID the Id of the token to list
    @param _reservePrice the minimum bid to start the auction
    @param _timeframe how long the auctions lasts
    @param _steps the min. amount that each bid needs to be apart in wei
    */
    function createReservePriceAuction(uint _tokenID, uint _reservePrice, uint _timeframe, uint _steps) public {
        // transfer the NFT to the contract
        itemToken.transferFrom(msg.sender, address(this), _tokenID);

        // create the auction order
        auctions[auctionCounter] = Auction({
            poster: msg.sender,
            tokenID: _tokenID,
            reservePrice: _reservePrice,
            highestBidder: msg.sender, /* for the time being set it to msg.sender */
            highestBid: _reservePrice, /* does not matter just yet */ 
            timePeriod: _timeframe,
            status: reservePriceAuctionStatus.NOTSTARTED,
            steps: _steps
        });

        // map the auctionID to the token ID
        AuctionIdByTokenId[_tokenID] = auctionCounter;

        auctionCounter++;

    }

    /* 
    @name buyFixedPriceListing
    @dev buy the listed NFT for the given Price
    @param _listingID to get all the information about the listed token
    */
    function buyFixedPriceListing(uint _listingID) public payable {   

        require(listings[_listingID].poster != address(0x0), "MARKET::Listing does not exist");
        
        FixedPriceListing memory listing = listings[_listingID];
        require(listing.status == fixedPriceListingStatus.OPEN, "Listing not open!"); 
        require(msg.value >= listing.price, "MARKET::Not enough ETH sent!");
        require(msg.sender != listing.poster, "MARKET::Cannot buy your own NFT!");

        /* 
        to do: 
            x verify the value=price && msg.sender != poster
            x verify that the listing is real
            x send the NFT to msg.sender
            x set the status of the listing to "Executed"
            x send ETH - fees to the poster
             subtract fees from the msg.value
        */

        // transfering tokens from the contract to the sender
        itemToken.transferFrom(address(this), msg.sender, listing.tokenID);

        // listing
        listings[_listingID].status = fixedPriceListingStatus.EXECUTED;

        // get the royalties 
        // price * bp / 10_0000
        uint _feeAmount = msg.value * fee / 10000;
        uint _royaltiesOfArtist = _getRoyaltiesByTokenID(listing.tokenID);

        // prevent revert incase the royaltie is zero
        if(_royaltiesOfArtist != 0) {
            // we compute the cut of the artist
            uint royaltieAmount = msg.value * _royaltiesOfArtist / 10000;
            // and transfer the remaining value to the seller
            listing.poster.transfer(msg.value - (_feeAmount + royaltieAmount)); 
            address payable artist = payable(_getCreatorOfToken(listing.tokenID));
            artist.transfer(royaltieAmount);

        } else {
            // the artist royalties are zero so we ignore it
            listing.poster.transfer(msg.value - _feeAmount);
        }
                
    }

    function _getRoyaltiesByTokenID(uint _tokenID) internal returns(uint){
        treespaceERC721 c = treespaceERC721(nftTokenAddress);
        return(c.getRoyaltiesOfToken(_tokenID));
    }

    function _getCreatorOfToken(uint _tokenID) internal returns (address) {
        treespaceERC721 c = treespaceERC721(nftTokenAddress);
        return(c.getCreatorOfToken(_tokenID));

    }

    /* 
    @name bidOnReservePriceAuction
    @dev bid on a reserve price auction
    @param _tokenID 

    @check auction must exist
    @check auction must be open or not started

    */
    function bidOnReservePriceAuction(uint auctionID) public payable {
        require(auctions[auctionID].poster != address(0x0), "MARKET::Listing does not exist");

        Auction memory _auctionData = auctions[auctionID];
        
        // if the auction has started
        if(_auctionData.status == reservePriceAuctionStatus.OPEN) {

            require(msg.sender != _auctionData.poster, "MARKET:Cannot bid on own NFT.");

            /* 
            to do
            * checks
            * add them as highest bidder
            * add the new highest bid
            */

            // require the bid to be bigger than the highestBid + steps
            require(msg.value >= _auctionData.highestBid + _auctionData.steps, "MARKET:Bid too low!");

            // 
            require(block.timestamp < auctionStart[auctionID] + _auctionData.timePeriod);
            
            // send the previous bid back to the previous highest bidder
            // make sure no reenrency is possible
            payable(_auctionData.highestBidder).transfer(_auctionData.highestBid);

            auctions[auctionID].highestBid = msg.value;
            auctions[auctionID].highestBidder = msg.sender;


        } else if (_auctionData.status == reservePriceAuctionStatus.NOTSTARTED) {
            // if the auction has not started
            require(msg.sender != _auctionData.poster, "MARKET:Cannot bid on own NFT.");
            require(msg.value >= _auctionData.reservePrice, "MARKET:Reserve Price not met. Bid higher.");

            // Open and add the timestamp 
            auctions[auctionID].status = reservePriceAuctionStatus.OPEN;
            auctions[auctionID].highestBid = msg.value;
            auctions[auctionID].highestBidder = msg.sender;
            auctionStart[auctionID] = block.timestamp;
        } else {revert("MARKET:Auction Status is either CANCELLED or EXECUTED");}

    }

    /*
    @name settleReservePriceAuction
    @dev callable by anyone 
    @param _auctionID the auction ID
    @check the auction needs to exist
    */
    function settleReservePriceAuction(uint _auctionID) public {
        require(auctions[auctionID].poster != address(0x0), "MARKET::Listing does not exist");
    }

}

interface treespaceERC721 {
    // limited interface
    function getRoyaltiesOfToken(uint _tokenId) external returns(uint);
    function getCreatorOfToken(uint _tokenID) external returns(address);
}