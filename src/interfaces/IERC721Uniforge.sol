// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ERC721Uniforge {

    error ERC721Uniforge__SaleIsNotOpen();
    error ERC721Uniforge__InvalidMintAmount();
    error ERC721Uniforge__MaxSupplyExceeded();
    error ERC721Uniforge__NeedMoreETHSent();
    error ERC721Uniforge__TransferFailed();

    event MintFeeUpdated(address indexed collection, uint256 indexed mintFee);
    event BatchMetadataUpdate(address indexed collection,string indexed baseURI);

    function mintNft(uint256 mintAmount) external payable;

    function creatorMint(address receiver, uint256 mintAmount) external;

    function withdraw() external; 

    function setMintFee(uint256 newMintFee) external;

    function setBaseURI(string memory newBaseURI) external;

    function baseURI() external view returns (string memory);

    function maxSupply() external view returns (uint256);
 
    function mintFee() external view returns (uint256);

    function maxBatchMint() external view returns (uint256);
  
    function saleStart() external view returns (uint256);
}
























