// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { ERC721A } from "ERC721A/ERC721A.sol";
import { Ownable } from "openzeppelin/access/Ownable.sol";

error ERC721Uniforge__SaleIsNotOpen();
error ERC721Uniforge__InvalidMintAmount();
error ERC721Uniforge__MaxSupplyExceeded();
error ERC721Uniforge__NeedMoreETHSent();
error ERC721Uniforge__TransferFailed();

/**
 * @title ERC721Uniforge
 * @author Dapponics
 * @notice ERC721Uniforge is an optimized and universal token contract
 *         that extends ERC721A with public sale capabilities.
 */
contract ERC721Uniforge is ERC721A, Ownable {
    uint256 private immutable _maxBatchMint;
    uint256 private immutable _maxSupply;
    uint256 private immutable _saleStart;
    string private _baseTokenURI;
    uint256 private _mintFee;

    event MintFeeUpdated(address indexed collection, uint256 indexed mintFee);
    event BatchMetadataUpdate(address indexed collection,string indexed baseURI);
   
    /**
     * @dev Transfers ownership to the client right at deployment and declare all the variables.
     * @param owner_ The address of the new owner of the contract.
     * @param name_ The name of the ERC721Uniforge token.
     * @param symbol_ The symbol of the ERC721Uniforge token.
     * @param baseURI_ The base URI of the ERC721Uniforge token metadata.
     * @param mintFee_ The cost of minting a single token.
     * @param maxBatchMint_ The maximum number of tokens that can be minted in a single transaction.
     * @param maxSupply_ The maximum total number of tokens that can be minted.
     * @param saleStart_ The timestamp representing the start time of the public sale.
     */
    constructor(
        address owner_,
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        uint256 mintFee_,
        uint256 maxBatchMint_,
        uint256 maxSupply_,
        uint256 saleStart_
    ) ERC721A (name_, symbol_) {
        transferOwnership(owner_);
        _baseTokenURI = baseURI_;
        _mintFee = mintFee_;
        _maxBatchMint = maxBatchMint_;
        _maxSupply = maxSupply_;
        _saleStart = saleStart_;
    }

    /**
     * @dev Mints `mintAmount` tokens to the caller of the function.
     * The caller has to send `mintFee`*`mintAmount` ethers and the sale should be open to mint.
     * The `mintAmount` has to be greater than 0 and less than or equal to `maxBatchMint`.
     * @param mintAmount The number of tokens to mint.
     */
    function mintNft(uint256 mintAmount) public payable {
        if (block.timestamp < _saleStart) {
            revert ERC721Uniforge__SaleIsNotOpen();
        }
        if (_totalMinted() + mintAmount > _maxSupply) {
            revert ERC721Uniforge__MaxSupplyExceeded();
        }
        if (mintAmount > _maxBatchMint) {
            revert ERC721Uniforge__InvalidMintAmount();
        }
        if (msg.value < _mintFee * mintAmount) {
            revert ERC721Uniforge__NeedMoreETHSent();
        }
        _safeMint(msg.sender, mintAmount);
    }

    /**
     * @dev Allows the contract owner to mint free tokens without time or mint limit constraints.
     * @param receiver The address to receive the minted tokens.
     * @param mintAmount The number of tokens to mint.
     */
    function creatorMint(
        address receiver,
        uint256 mintAmount
    ) public onlyOwner {
        if (_totalMinted() + mintAmount > _maxSupply) {
            revert ERC721Uniforge__MaxSupplyExceeded();
        }
        _safeMint(receiver, mintAmount);
    }

    /**
     * @dev Allows the contract owner to withdraw the Ether balance of the contract.
     */
    function withdraw() public onlyOwner {
        (bool _ownerSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!_ownerSuccess) {
            revert ERC721Uniforge__TransferFailed();
        }
    }

    /**
     * @dev Allows the contract owner to set the fee required to mint a single token.
     * @param newMintFee The fee of minting a single token.
     */
    function setMintFee(uint256 newMintFee) public onlyOwner {
        _mintFee = newMintFee;
        emit MintFeeUpdated(address(this), _mintFee);
    }

    /**
     * @dev Allows the contract owner to set the base URI of the ERC721Uniforge token metadata.
     * @param newBaseURI The new base URI.
     */
    function setBaseURI(string memory newBaseURI) public onlyOwner {
        _baseTokenURI = newBaseURI;
        emit BatchMetadataUpdate(address(this), newBaseURI);
    }

    /**
    * @dev Helper function for update the metadata of the contract.
    */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Returns the base URI of the ERC721 token metadata.
     */
    function baseURI() public view returns (string memory) {
        return _baseURI();
    }

    /**
     * @dev Returns the maximum total number of tokens that can be minted.
     */
    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    /**
     * @dev Returns the fee for minting a single token.
     */
    function mintFee() public view returns (uint256) {
        return _mintFee;
    }

    /**
     * @dev Returns the maximum number of tokens that can be minted in a single transaction.
     */
    function maxBatchMint() public view returns (uint256) {
        return _maxBatchMint;
    }

    /**
     * @dev Returns the starting timestamp of the public sale.
     */
    function saleStart() public view returns (uint256) {
        return _saleStart;
    }
}



