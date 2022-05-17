// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../openzeppelin/token/ERC721/ERC721.sol";
import "../openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";
import "../openzeppelin/token/ERC721/extensions/ERC721URIStorage.sol";
import "../openzeppelin/access/Ownable.sol";
import "../openzeppelin/utils/Counters.sol";



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

/// @custom:security-contact support@treespace.xyz
contract Treespace is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Treespace", "TREE") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ar://";
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

    // tokenID => creator
    mapping(uint => address) public creatorOfToken;

    // tokenID => basispointsRoyalties
    mapping(uint => uint) public marketplaceRoyalties;

    // permissioned minting - by default true
    // means only approved addresses can mint
    bool public permissionedMinting = true;

    // if _permissionedMinting = true, only these addresses 
    // can call the mint function
    mapping (address => bool) public approvedAddresses;

    // max royalties - default to 1000 or 10%
    uint _maxRoyalties = 1000;

    /*
    EVENTS
    ---------------
    */

    event MintReceipt(string indexed _URI, uint _royaltiesBasisPoints, uint indexed _tokenID, address indexed _minter);
    event changedMarketplaceRoyalties(uint indexed _tokenID, uint _newBasisPoints);


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
    function mint(string memory _URI, uint _royaltiesBasisPoints) public {
        if(permissionedMinting == true) {
            // check if the address has been approved
            require(approvedAddresses[msg.sender] == true, "ERC721::Mint:Not authorized to mint.");
            _mintToken(_URI, _royaltiesBasisPoints);
        } else {
            // minting is open for all
            _mintToken(_URI, _royaltiesBasisPoints);
        }
    }   

    // mint a token
    function _mintToken(string memory _URI, uint _royaltiesBasisPoints) internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _URI);

        // set the royalties
        _setMarketplaceRoyalties(_royaltiesBasisPoints, tokenId);

        // remember the creator
        creatorOfToken[tokenId] = msg.sender;
        
        emit MintReceipt(_URI, _royaltiesBasisPoints, tokenId, msg.sender);
    }



    /* 
    @dev set the royalties for the NFT
    @param _basispoints max. 10_000
    @param _tokenID 
    */
    function _setMarketplaceRoyalties(uint _basispoints, uint _tokenID) internal {
        require(_basispoints <= _maxRoyalties, "ERC721::_setMarketplaceRoyalties:Royalities must be below or equal to 30 percent!");

        // set the royalties for the NFT
        marketplaceRoyalties[_tokenID] = _basispoints;
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

    /*
    ADMISSION COUNCIL FUNCTIONS
    -----------------
    These functions can only be called by the addmissions council. 
    For Managing permission. 
    */

    address addmissionCouncilDAO;
    bool addmissionsCouncilPaused;

    function permitMinters(address[] memory _permitedMinters) external {
        require(msg.sender == addmissionCouncilDAO, "ERC721::permitMinters:Not authorized.");
        require(addmissionsCouncilPaused != true, "ERC721::permitMinters:Addmissions Council Paused");
        
        for(uint i; i < _permitedMinters.length; i++) {
            approvedAddresses[_permitedMinters[i]] = true;
        }
    }

    function removePermitedMinters(address[] memory _targetAddresses) external {
        require(msg.sender == addmissionCouncilDAO, "ERC721::removePermitedMinters:Not authorized.");
        require(addmissionsCouncilPaused != true, "ERC721::removePermitedMinters:Addmissions Council Paused");

        for(uint i; i < _targetAddresses.length; i++) {
            approvedAddresses[_targetAddresses[i]] = false;
        }
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
