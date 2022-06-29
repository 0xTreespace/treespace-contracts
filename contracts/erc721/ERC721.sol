// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./marketplaceConfig.sol";
import "./admissionCouncil.sol";

/* 
                                                                                                                                                   
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(/&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@//////////////////////////(@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@/////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@/////////////////////////////////@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@/////////////////////////////////////@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@////////////////////////////////////////%@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@///////////////////////////////////////////@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@///////////////////////////////////////////////@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@///////////////////////////////////////////////////@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@/////////////////////////////////////////@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@/////////////////////////////////////////////@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@(///////////////////////////////////////////////#@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@///////////////////////////////////////////////////@@@@@@@@@@@@@@
@@@@@@@@@@@@@///////////////////////////////////////////////////////@@@@@@@@@@@@
@@@@@@@@@@@///////////////////////////////////////////////////////////@@@@@@@@@@
@@@@@@@@@%/////////////////////////////////////////////////////////////@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///////////////////@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@title ERC721 contract for the treespace NFTs                                                                                                                                                

*/

// @custom:security-contact support@treespace.xyz

contract Treespace is ERC721, ERC721Enumerable, ERC721URIStorage, MarketplaceConfig, Ownable, AdmissionCouncil {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    IERC721 itemToken;

    constructor() ERC721("Treespace", "TREE") {
        itemToken = IERC721(address(this));
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
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

    // ------------------------------------------------------------
    // --------------------- Custom Functions ---------------------
    // ------------------------------------------------------------
    // Not part of the ERC721 standard

    // only approved addresses can mint
    bool public permissionedMinting = false;

    /*
    EVENTS
    ---------------
    */

    event MintReceipt(string indexed _URI, uint _royaltiesBasisPoints, uint indexed _tokenID, address indexed _minter);

    /*
    MINT FUNCTION
    ---------------
        - check if mintable by anyone
        - mint the NFT if checks passed

    @title publicMint
    @dev allows anyone to mint an NFT to the contract
    @param URI the IPFS hash pointing to the metadata
    @param _royaltiesBasisPoints the Royalties to be set
    */
    function mint(string memory _URI, uint _royaltiesBasisPoints, address _royaltieReceiver) public {
        require(_royaltieReceiver != address(0x0), "Royaltie Address invalid.");
        if(permissionedMinting == true) {
            // check if the address has been approved
            require(approvedAddresses[msg.sender] == true, "ERC721::Mint:Not authorized to mint.");
            _mintToken(_URI, _royaltiesBasisPoints, _royaltieReceiver);
        } else {
            // minting is open for all
            _mintToken(_URI, _royaltiesBasisPoints, _royaltieReceiver);
        }
    }

    // mint a token
    function _mintToken(string memory _URI, uint _royaltiesBasisPoints, address _royaltieReceiver) internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _URI);

        // set the royalties
        _setMarketplaceRoyalties(_royaltiesBasisPoints, tokenId, _royaltieReceiver);

        // remember the creator
        creatorOfToken[tokenId] = msg.sender;
        createdTokensByAddress[msg.sender].push(tokenId);

        emit MintReceipt(_URI, _royaltiesBasisPoints, tokenId, msg.sender);
    }


    /*
    GOVERNANCE FUNCTIONS:
    ------------------------
    These functions can be called by the governance contract to change paramters.
    All onlyOwner functions. Ownership will be transfered to the governance Contract.

    To do:
        - changePermissionedMinting
        - add/ remove artists
        - change Royaltie Paramters (max, changable)

    */

    function changePermissionedMinting(bool _targetValue) external onlyOwner {
        permissionedMinting = _targetValue;
    }

    function changeMaxMarketplaceRoyalties(uint _newMaxRoyalties) external onlyOwner {
        _maxRoyalties = _newMaxRoyalties;
    }

    function changeAddmissionCouncilStatus(bool _targetValue) external onlyOwner {
        addmissionsCouncilPaused = _targetValue;
    }

    // POLICING FUNCTIONS
    // these are used to give the DAO the ability to regulate the minted tokens
    // only to be used as a last resort and in an emergency.
    // not effective or effecient because of the proposal process

    // burns a token
    function burnToken(uint _tokenId) external onlyOwner {
        _burn(_tokenId);
    }

    // change the URI of a token
    function changeUriOfToken(uint _tokenId, string memory _newURI) external onlyOwner {
        _setTokenURI(_tokenId, _newURI);
    }
}
