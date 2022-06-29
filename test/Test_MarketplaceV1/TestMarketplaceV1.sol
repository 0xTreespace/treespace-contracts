// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../../contracts/erc721/ERC721.sol";
import "../../contracts/Interface/ITreespaceProvider.sol";
import "../../contracts/marketplace/MarketplaceV1/MarketplaceV1.sol";
import "../../contracts/Interface/tIERC721.sol";

contract TestMarketplaceV1 {

    ITreespaceProvider treespaceProvider = ITreespaceProvider(DeployedAddresses.TreespaceProvider());
    tIERC721 itemToken = tIERC721(DeployedAddresses.ERC721());

    /*
    Testing Marketplace Buying and Selling functionality
    First we need to mint an NFT

    */

    function testMarketplaceV1() public {
        uint test1 = 2;
        uint test2 = 2;
        Assert.equal(test1, test2, "NOT EQUAL");
    }
}