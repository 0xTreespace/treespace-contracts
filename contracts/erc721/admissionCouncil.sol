// SPDX-License-Identifier: MIT
pragma solidity ^8.0.4;

// Provides the logic used by the Admission Council

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

}