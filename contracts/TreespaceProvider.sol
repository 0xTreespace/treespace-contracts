// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// aggregates contract addesses and data used by multiple contracts
// Ownership over the contract will be transfered to the DAO contract 

import "@openzeppelin/contracts/access/Ownable.sol";

contract TreespaceProvider is Ownable {
    
    address[] marketplaceContracts;
    address erc721Contract;
    address treespaceProfile;

    uint marketplaceFees;
    // max Basispoint value for the fee - to protect sellers from governance attacks
    uint MaxBP;

    constructor(
        address[] _marketplaceContracts,
        address _erc721Contract,
        address _treespaceProfile,
        uint _MaxBP,
        uint _marketplaceFees
    ) {
        marketplaceContracts = _marketplaceContracts;
        erc721Contract = _erc721Contract;
        treespaceProfile = _treespaceProfile;
        MaxBP = _MaxBP;
        marketplaceFees = _marketplaceFees;
    }

    function getMarketplaceContractArrayLenght() public view returns (uint) {
        return marketplaceContracts.lenght;
    }

    function getMarketplaceContractByIndex(uint _index) public view returns (address) {
        return marketplaceContracts[_index];
    }

    function getERC721Contract() public view returns (address) {
        return erc721Contract;
    }

    function getTreespaceProfileContract() public view returns (address) {
        return treespaceProfile;
    }

    function getMarketplaceFees() public view returns (uint) {
        return marketplaceFees;
    }

    /*
    GOVERNANCE FUNCTIONS
    --------------------
    These are used to change or add Contract addresses
    */

    function changeTreespaceProfile(address _newContract) public onlyOwner {
        treespaceProfile = _newContract;
    }

    function changeERC721Contract(address _newContract) public onlyOwner {
        erc721Contract = _newContract;
    }

    // 0 - remove
    // 1 - add
     function manageMarketplaceContracts(uint _operation, address _target) public onlyOwner {
        require(_operation < 2, "TREESPACEPROVIDER::manageMarketplaceContracts:Operation value out of range");
        if(_operation == 0) { 
            // remove
            delete _marketplaceContracts[_target];
        } else {
            _marketplaceContracts.push(_target);
        }
     }

     function setMarketplaceFees(uint _target) public onlyOwner {
        // fees cannot be zero right now
        // basispoints - 100 = 1%

        require(_target > 0, "TREESPACEPROVIDER::setMarketplaceFees:Fee cannot be set to zero");
        require(_target < MaxBP, "TREESPACEPROVIDER::setMarketplaceFees:Fee must be below MAXBP value.");

        marketplaceFees = _target;
     }


}