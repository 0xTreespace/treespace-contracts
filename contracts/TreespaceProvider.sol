pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TreespaceProvider is Ownable {
    // aggregates Data used by multiple contracts
    
    address[] marketplaceContracts;
    address erc721Contract;
    address treespaceProfile;

    constructor(
        address[] _marketplaceContracts,
        address _erc721Contract,
        address _treespaceProfile
    ) {
        marketplaceContracts = _marketplaceContracts;
        erc721Contract = _erc721Contract;
        treespaceProfile = _treespaceProfile;
    }

    function getMarketplaceContractLenght() public view returns (uint) {
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
        require(_operation < 2, "TREESPACEPROVIDER::manageMarketplaceContracts:Operation needs to be smaller");
        if(_operation == 0) {
            // remove
            delete _marketplaceContracts[_target];
        } else {
            _marketplaceContracts.push(_target);
        }
     }

}