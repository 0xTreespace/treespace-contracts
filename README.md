# Treespace Contracts
This repository contains all the cotracts for the treespace protocol which is currently under development. 
## Structure 
Treespace consists of 3 different components.
- ERC721 Contract
- Marketplace Contract
- Governance Contracts
### ERC721 Contract
All NFTs tradable on the treespace marketplace are minted on this contract. Minting is permissioned by default but can be changed by the DAO. Addresses which are permitted by the Contract to mint are stored in an array. Royalties are also stored directly in the contract. 
### Marketplace Contract
The inital Marketplace Contract will support the following features: 
- fixed-price Listings
- reserve-price Auctions
- passive Bids (on listed and unlisted NFTs)
### Governance Contracts 
The governance System consist of 3 different components. 
- LEAFs (Governance NFTs)
    These are used to vote on proposals and earn a (by the DAO) delegated amount of trading fees.
- Tresury
- DAO Logic 
    This contract holds and executed all proposals.
- Staking Contract
    - Staked "LEAFs" earn ETH (trading fees)
    - Staked "LEAFs" also count as votes