// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Provides the logic used by the Admission Council

// they permit users to mint

contract AdmissionCouncil {
    
    // if _permissionedMinting = true, only these addresses
    // can call the mint function
    mapping (address => bool) public approvedAddresses;

    /*
    ADMISSION COUNCIL FUNCTIONS
    -----------------
    These functions can only be called by the addmissions council.
    For Managing permission.
    */

    address addmissionCouncilDAO;
    bool addmissionsCouncilPaused;

    /*
    @dev function too permit single address to mint
    @param _permittedMinter the address to permit
    @check1 check if the addmission council is calling the function
    @check2 check if the addmissions council is paused
    */
    function permitMinter(address _permittedMinter) external {
        require(msg.sender == addmissionCouncilDAO, "ERC721::permitMinter:Not authorized.");
        require(addmissionsCouncilPaused != true, "ERC721::permitMinter:Addmissions Council Paused");

        approvedAddresses[_permittedMinter] = true;
    }

    /*
    @dev function to remove minting permission for a certain address
    @param address to revoke
    @check1 check if the addmission council is calling the function
    @check2 check if the addmissions council is paused
    */

    function revokeMintingPermission(address _addressToRevoke) external {
        require(msg.sender == addmissionCouncilDAO, "ERC721::revokeMintingPermission:Not authorized.");
        require(addmissionsCouncilPaused != true, "ERC721::revokeMintingPermission:Addmissions Council Paused");

        approvedAddresses[_addressToRevoke] = false;
    }

}


/*
    UNUSED CODE
    -----------
    Might still use it so that is why it's here.

    function permitMinters(address[] _permitedMinters) external {
        require(msg.sender == addmissionCouncilDAO, "ERC721::permitMinters:Not authorized.");
        require(addmissionsCouncilPaused != true, "ERC721::permitMinters:Addmissions Council Paused");

        for(uint i; i < _permitedMinters.length; i++) {
            approvedAddresses[_permitedMinters[i]] = true;
        }
    }


    function removePermitedMinters(address[] _targetAddresses) external {
        require(msg.sender == addmissionCouncilDAO, "ERC721::removePermitedMinters:Not authorized.");
        require(addmissionsCouncilPaused != true, "ERC721::removePermitedMinters:Addmissions Council Paused");

        for(uint i; i < _targetAddresses.length; i++) {
            approvedAddresses[_targetAddresses[i]] = false;
        }
    }

*/