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
        - listNFT
            -- as auction
            -- as fixed price listing
        - withdraw listing
            -- withdraw fixedPricedListing
            -- cancel reservePriceAuction
        - buy fixedPricedListing
        - bid on NFT (bid >= reserve price)
        - withdraw expired Bid on NFT
        - add royalties
            -- percentage set by user
            -- embed in the ERC721 contract
                --- set on creation
    */

    // the identifier to match auctions and fixed price listings 
    uint public listingCounter;
    uint public auctionCounter;

    struct Trade {
        address payable poster;
        uint256 tokenID;
        uint256 price;
        bytes32 status; // Open, Executed, Cancelled    
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
        bytes32 status; // Open, Executed, Cancelled    

    }

    mapping(uint => Trade) public listings;
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
        listings[listingCounter] = Trade({
            poster: payable(msg.sender),
            tokenID: _tokenID,
            price: _price,
            status: "Open"
        
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
    */
    function createReservePriceAuction(uint _tokenID, uint _reservePrice, uint _timeframe) public {
        // transfer the NFT to the contract
        itemToken.transferFrom(msg.sender, address(this), _tokenID);

        // create the auction order
        auctions[auctionCounter] = Auction({
            poster: msg.sender,
            tokenID: _tokenID,
            reservePrice: _reservePrice,
            highestBidder: msg.sender, /* for the time being */
            highestBid: _reservePrice, /* does not matter just yet */ 
            timePeriod: _timeframe,
            status: "notStarted"
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
        
        Trade memory listing = listings[_listingID];
        require(listing.status == "Open", "Listing not open!"); 
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
        listing.status = "Executed";

        uint marketplaceCut = msg.value * fee / 10000; // gets 1 %
        
        // sending the amount 
        listing.poster.transfer(msg.value - marketplaceCut); 
        
    }

    function callERCContract(uint tokenID) public returns(uint){
        treespaceERC721 c = treespaceERC721(nftTokenAddress);
        return(c.getRoyaltiesOfToken(tokenID));
    }

}

interface treespaceERC721 {
    // limited interface
    function getRoyaltiesOfToken(uint _tokenId) external returns(uint);
}