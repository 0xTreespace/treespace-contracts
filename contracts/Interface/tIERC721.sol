pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/* 
The Interface for specific functions used by other contracts
*/

interface tIERC721 is IERC721{
    function getCreatorOfToken(uint) external returns(address);
    function getRoyaltiesOfToken(uint) external returns(uint);
    function getRoyaltieReceiver(uint) external returns(address);
}