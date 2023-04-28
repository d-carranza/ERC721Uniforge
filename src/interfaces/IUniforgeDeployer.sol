// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface UniforgeDeployer {

    error UniforgeDeployer__NeedMoreETHSent();
    error UniforgeDeployer__TransferFailed();
    error UniforgeDeployer__InvalidDiscount();

    event NewCollectionCreated(address indexed collection);
    event DeployFeeUpdated(uint256 indexed deployFee);
    event NewCreatorDiscount(address indexed creator, uint256 indexed discount);
   
    function deployNewCollection(
        address owner,
        string memory name,
        string memory symbol,
        string memory baseURI,
        uint256 mintFee,
        uint256 maxBatchMint,
        uint256 maxSupply,
        uint256 saleStart
    ) external payable;
   
    function setDeployFee(uint256 fee) external;
  
    function setCreatorDiscount(address creator, uint256 percentage) external;
    
    function withdraw() external;
    
    function deployments() external view returns (uint256);

    function deployment(uint256 index) external view returns (address);

    function deployFee() external view returns (uint256);

    function creatorDiscount(address creator) external view returns (uint256);

    function creatorFee(address creator) external view returns (uint256);
}

















