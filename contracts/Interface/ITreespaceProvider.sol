// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// the interface for the treespace Provider

interface ITreespaceProvider {
    function getMarketplaceContractArrayLenght() external view returns (uint);
    function getMarketplaceContractByIndex(uint _index) external view returns (address);
    function getERC721Contract() external view returns (address);
    function getTreespaceProfileContract() external view returns (address);
    function getMarketplaceFees() external view returns (uint);

    function changeTreespaceProfile(address _newContract) external;
    function changeERC721Contract(address _newContract) external;

    function removeMarketplaceContract(uint _target) external;
    function addMarketplaceContract(address _newContract) external;

    function setMarketplaceFees(uint _target) external;
}