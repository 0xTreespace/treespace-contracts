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
        address[] memory _marketplaceContracts,
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
        return marketplaceContracts.length;
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

    // @param _target the index of the marketplace contract to be operated on
    // @param _newMarketplace can be set to address(0x0) if target gets removed
     function removeMarketplaceContract(uint _target) public onlyOwner {
        delete marketplaceContracts[_target];
     }

     function addMarketplaceContract(address _newContract) public onlyOwner {
        marketplaceContracts[getMarketplaceContractArrayLenght()] = _newContract;
     }

     function setMarketplaceFees(uint _target) public onlyOwner {
        // basispoints - 100 = 1%

        require(_target < MaxBP, "TREESPACEPROVIDER::setMarketplaceFees:Fee must be below MAXBP value.");

        marketplaceFees = _target;
     }


}