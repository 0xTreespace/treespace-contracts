pragma solidity ^0.8.4;

/* 
The Interface for specific functions used by other contracts
*/

interface tIERC721 {
    function getCreatorOfToken(uint) external returns(address);
    function getRoyaltiesOfToken(uint) external returns(uint);
    function getRoyaltieReceiver(uint) external returns(address);
}