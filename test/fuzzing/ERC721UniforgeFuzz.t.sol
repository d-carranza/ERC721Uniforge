// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "src/ERC721Uniforge.sol";
import "lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract ERC721UniforgeFuzzTest is Test {
    using Strings for uint256;
    ERC721Uniforge public erc721uniforge;

    address deployer = 0x46ac62Ea156A7476b087B986Ea312Bae06279A0C;
    address owner = 0x46ac62Ea156A7476b087B986Ea312Bae06279A0C;
    address minter = 0x710E272C2052eEfa1a1A67ef347D19B9fE4bEc75;

    event MintFeeUpdated(
        address indexed collectionAddress,
        uint256 indexed newMintFee
    );
    event MaxMintAmountUpdated(
        address indexed collectionAddress,
        uint256 indexed newMaxMintAmount
    );
    event MaxSupplyUpdated(
        address indexed collectionAddress,
        uint256 indexed newMaxSupply
    );
    event SaleStartUpdated(
        address indexed collectionAddress,
        uint256 indexed newSaleStart
    );

    function setUp() public {
        vm.prank(deployer);
        erc721uniforge = new ERC721Uniforge(
            owner,
            "Dappenics",
            "DAPE",
            "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/",
            1e16,
            2,
            10000,
            1
        );
        deal(minter, 1e20);
    }

    function testFuzz_MintNft(uint256 _mintAmount) public {
        vm.assume(_mintAmount != 0);
        vm.assume(_mintAmount <= erc721uniforge.maxBatchMint());
        vm.prank(minter);
        erc721uniforge.mintNft{value: _mintAmount * 1e16}(_mintAmount);
        assertEq(erc721uniforge.totalSupply(), _mintAmount);
    }

    function testFuzz_FreeMintForAddress_Owner(
        address _receiver,
        uint256 _mintAmount
    ) public {
        vm.assume(_mintAmount != 0);
        vm.assume(_mintAmount <= erc721uniforge.maxSupply());
        vm.prank(owner);
        erc721uniforge.creatorMint(_receiver, _mintAmount);
        assertEq(erc721uniforge.totalSupply(), _mintAmount);
    }

    function testFuzz_SetBaseURI_Owner(string memory _baseURI) public {
        vm.prank(owner);
        erc721uniforge.setBaseURI(_baseURI);
        assertEq(erc721uniforge.baseURI(), _baseURI);
    }

    function test_SetMintFee_Owner(uint256 _mintFee) public {
        vm.prank(owner);
        vm.expectEmit(true, true, false, false);
        emit MintFeeUpdated(address(erc721uniforge), _mintFee);
        erc721uniforge.setMintFee(_mintFee);
        assertEq(erc721uniforge.mintFee(), _mintFee);
    }

    function testFuzz_tokenURI(uint256 _tokenId) public {
        deal(owner, 1e18);
        vm.prank(owner);
        erc721uniforge.creatorMint(minter, 100);
        assertEq(erc721uniforge.totalSupply(), 100);
        vm.assume(_tokenId < erc721uniforge.totalSupply());
        assertEq(
            erc721uniforge.tokenURI(_tokenId),
            string(
                abi.encodePacked(
                    "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/",
                    _tokenId.toString()
                )
            )
        );
    }
}
