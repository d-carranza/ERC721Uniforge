// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Ownable} from "openzeppelin/access/Ownable.sol";
import {ERC721Uniforge} from "./ERC721Uniforge.sol";

error UniforgeDeployer__NeedMoreETHSent();
error UniforgeDeployer__TransferFailed();
error UniforgeDeployer__InvalidDiscount();

/**
 * @title UniforgeDeployer
 * @author Diego Carranza @Dapponics
 * @notice UniforgeDeployer is a smart contract factory 
 * that enables the creation of ERC721Uniforge contracts
 * and contains methods to interact with Uniforge.
 */
contract UniforgeDeployer is Ownable {
    uint256 private _deployFee;
    uint256 private _collectionCounter;
    mapping(uint256 => address) private _collection;
    mapping(address => uint256) private _creatorDiscount;

    event NewCollectionCreated(address indexed collection);
    event DeployFeeUpdated(uint256 indexed deployFee);
    event NewCreatorDiscount(address indexed creator, uint256 indexed discount);

    /**
     * @dev Transfers ownership to a new owner at the contract creation.
     * @param owner The address of the new owner of the UniforgeDeployer contract.
     */
    constructor(address owner) {
        transferOwnership(owner);
    }

    /**
     * @dev Allows the caller to deploy a new Uniforge Collection.
     * @param owner The address of the new owner of the new UniforgeCollection contract.
     * @param name The name of the ERC721 token.
     * @param symbol The symbol of the ERC721 token.
     * @param baseURI The base URI of the ERC721 token metadata.
     * @param mintFee The cost of minting a single token.
     * @param maxBatchMint The maximum number of tokens that can be minted in a single transaction.
     * @param maxSupply The maximum total number of tokens that can be minted.
     * @param saleStart The timestamp representing the start time of the public sale.
     */
    function deployNewCollection(
        address owner,
        string memory name,
        string memory symbol,
        string memory baseURI,
        uint256 mintFee,
        uint256 maxBatchMint,
        uint256 maxSupply,
        uint256 saleStart
    ) public payable {
        uint256 _discountPercentage = 100 - _creatorDiscount[msg.sender];
        uint256 _finalPrice = (_deployFee * _discountPercentage) / 100;
        if (msg.value < _finalPrice) {
            revert UniforgeDeployer__NeedMoreETHSent();
        }
        address _newCollection = address(
            new ERC721Uniforge(
                owner,
                name,
                symbol,
                baseURI,
                mintFee,
                maxBatchMint,
                maxSupply,
                saleStart
            )
        );

        _collection[_collectionCounter] = address(_newCollection);
        _collectionCounter += 1;
        emit NewCollectionCreated(address(_newCollection));
    }

    /**
     * @dev Allows the contract owner to set the fee required to deploy a new Uniforge Collection.
     * @param fee The new deployment fee amount.
     */
    function setDeployFee(uint256 fee) public onlyOwner {
        _deployFee = fee;
        emit DeployFeeUpdated(_deployFee);
    }

    /**
     * @dev Allows the contract owner to provide a discount to a specific customer.
     * @param creator The address of the customer who gets the discount.
     * @param percentage The percentage of the discount provided.
     */
    function setCreatorDiscount(address creator, uint256 percentage) public onlyOwner {
        if (percentage > 99) {
            revert UniforgeDeployer__InvalidDiscount();
        }
        _creatorDiscount[creator] = percentage;
        emit NewCreatorDiscount(creator, percentage);
    }

    /**
     * @dev Allows the contract owner to withdraw the Ether balance of the contract.
     */
    function withdraw() public onlyOwner {
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        if (!success) {
            revert UniforgeDeployer__TransferFailed();
        }
    }

    /**
     * @dev Returns the number of Uniforge Collections deployed through this contract.
     */
    function deployments() public view returns (uint256) {
        return _collectionCounter;
    }

    /**
     * @dev Returns the address of a specific deployed Uniforge Collection.
     * @param index The index of the deployed collection.
     */
    function deployment(uint256 index) public view returns (address) {
        return _collection[index];
    }

    /**
     * @dev Returns the deployment fee required to deploy a new Uniforge Collection.
     */
    function deployFee() public view returns (uint256) {
        return _deployFee;
    }

    /**
     * @dev Returns the discount percentage for a specific customer.
     * @param creator The address of the customer.
     */
    function creatorDiscount(address creator) public view returns (uint256) {
        return _creatorDiscount[creator];
    }

    /**
     * @dev Returns the final price required to deploy a new Uniforge Collection.
     * @param creator The address of the customer.
     */
    function creatorFee(address creator) public view returns (uint256) {
        uint256 _discountPercentage = 100 - _creatorDiscount[creator];
        return (_deployFee * _discountPercentage) / 100;
    }
}