// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "src/ERC721Uniforge.sol";

contract ERC721UniforgeTest is Test {
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
            2
        );
        deal(minter, 1e20);
        vm.warp(3);
    }

    function test_Constructor_DeployerBecomesOwner() public {
        assertEq(erc721uniforge.owner(), owner);
    }

    function test_Constructor_BaseURIStored() public {
        assertEq(
            erc721uniforge.baseURI(),
            "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/"
        );
    }

    function test_Constructor_MintFeeStored() public {
        assertEq(erc721uniforge.mintFee(), 1e16);
    }

    function test_Constructor_MaxMintAmountStored() public {
        assertEq(erc721uniforge.maxBatchMint(), 2);
    }

    function test_Constructor_MaxSupplyStored() public {
        assertEq(erc721uniforge.maxSupply(), 10000);
    }

    function test_Constructor_SaleStartStored() public {
        assertEq(erc721uniforge.saleStart(), 2);
    }

    function test_MintNft_ZeroMintAmountReverts() public {
        vm.prank(minter);
        vm.expectRevert();
        erc721uniforge.mintNft(0);
    }

    function test_MintNft_LessMintAmount() public {
        vm.prank(minter);
        erc721uniforge.mintNft{value: 1e16}(1);
        assertEq(erc721uniforge.totalSupply(), 1);
    }

    function test_MintNft_EqualMintAmount() public {
        vm.prank(minter);
        erc721uniforge.mintNft{value: 2 * 1e16}(2);
        assertEq(erc721uniforge.totalSupply(), 2);
    }

    function test_MintNft_MoreMintAmountReverts() public {
        vm.prank(minter);
        vm.expectRevert(ERC721Uniforge__InvalidMintAmount.selector);
        erc721uniforge.mintNft(3);
    }

    function test_MintNft_ClosedSaleReverts() public {
        vm.warp(1);
        vm.prank(minter);
        vm.expectRevert(ERC721Uniforge__SaleIsNotOpen.selector);
        erc721uniforge.mintNft{value: 1e16}(1);
    }

    function test_MintNft_ZeroEthReverts() public {
        vm.prank(minter);
        vm.expectRevert(ERC721Uniforge__NeedMoreETHSent.selector);
        erc721uniforge.mintNft(1);
    }

    function test_MintNft_ZeroEthSucceedsWhenMintFeeZero() public {
        vm.prank(owner);
        erc721uniforge.setMintFee(0);
        vm.prank(minter);
        erc721uniforge.mintNft(1);
        assertEq(erc721uniforge.totalSupply(), 1);
    }

    function test_MintNft_LessEthReverts() public {
        vm.prank(minter);
        vm.expectRevert(ERC721Uniforge__NeedMoreETHSent.selector);
        erc721uniforge.mintNft{value: 1e15}(1);
    }

    function test_MintNft_EqualEth() public {
        vm.prank(minter);
        erc721uniforge.mintNft{value: 1e16}(1);
        assertEq(erc721uniforge.totalSupply(), 1);
    }

    function test_MintNft_MoreEth() public {
        vm.prank(minter);
        erc721uniforge.mintNft{value: 1e17}(1);
        assertEq(erc721uniforge.totalSupply(), 1);
    }

    function test_MintNFT_RevertsWhenMintMoreThanSupply() public {
        vm.prank(owner);
        erc721uniforge.creatorMint(msg.sender, 10000);
        vm.prank(minter);
        vm.expectRevert(ERC721Uniforge__MaxSupplyExceeded.selector);
        erc721uniforge.mintNft{value: 1e17}(1);
    }

    function test_CreatorMint_OwnerMintsSelf() public {
        vm.prank(owner);
        erc721uniforge.creatorMint(msg.sender, 1);
        assertEq(erc721uniforge.totalSupply(), 1);
    }

    function test_CreatorMint_OwnerMintsToOther() public {
        vm.prank(owner);
        erc721uniforge.creatorMint(minter, 1);
        assertEq(erc721uniforge.totalSupply(), 1);
    }

    function test_CreatorMint_OwnerMintsMore() public {
        vm.prank(owner);
        erc721uniforge.creatorMint(msg.sender, 5);
        assertEq(erc721uniforge.totalSupply(), 5);
    }

    function test_CreatorMint_NotOwnerReverts() public {
        vm.prank(minter);
        vm.expectRevert("Ownable: caller is not the owner");
        erc721uniforge.creatorMint(minter, 5);
    }

    function test_CreatorMint_RevertsWhenMintMoreThanSupply() public {
        vm.startPrank(owner);
        vm.expectRevert(ERC721Uniforge__MaxSupplyExceeded.selector);
        erc721uniforge.creatorMint(msg.sender, 10001);
    }

    function test_SetBaseURI_OwnerUpdatesBaseURI() public {
        vm.prank(owner);
        erc721uniforge.setBaseURI("hello");
        assertEq(erc721uniforge.baseURI(), "hello");
    }

    function test_SetBaseURI_NotOwnerReverts() public {
        vm.prank(minter);
        vm.expectRevert("Ownable: caller is not the owner");
        erc721uniforge.setBaseURI("hello");
    }

    function test_SetMintFee_OwnerUpdatesFee() public {
        vm.prank(owner);
        vm.expectEmit(true, true, false, false);
        emit MintFeeUpdated(address(erc721uniforge), 1e18);
        erc721uniforge.setMintFee(1e18);
        assertEq(erc721uniforge.mintFee(), 1e18);
    }

    function test_SetMintFee_NotOwnerReverts() public {
        vm.prank(minter);
        vm.expectRevert("Ownable: caller is not the owner");
        erc721uniforge.setMintFee(1e18);
    }

    function test_Withdraw_OwnerWithdrawSuccessfully() public {
        uint256 initialBalance = owner.balance;
        vm.prank(minter);
        erc721uniforge.mintNft{value: 1e16}(1);
        vm.prank(owner);
        erc721uniforge.withdraw();
        assertEq(owner.balance, initialBalance + 1e16);
    }

    function test_Withdraw_NotOwnerReverts() public {
        vm.startPrank(minter);
        erc721uniforge.mintNft{value: 1e16}(1);
        vm.expectRevert("Ownable: caller is not the owner");
        erc721uniforge.withdraw();
    }

    function test_Withdraw_FailedCallReverts() public {
        vm.prank(owner);
        erc721uniforge.transferOwnership(address(this));
        vm.prank(address(this));
        vm.expectRevert(ERC721Uniforge__TransferFailed.selector);
        erc721uniforge.withdraw();
    }

    function test_MaxSupply() public {
        assertEq(erc721uniforge.maxSupply(), 10000);
    }

    function test_MintFee() public {
        assertEq(erc721uniforge.mintFee(), 1e16);
    }

    function test_MaxMintAmount() public {
        assertEq(erc721uniforge.maxBatchMint(), 2);
    }

    function test_SaleStart() public {
        assertEq(erc721uniforge.saleStart(), 2);
    }

    function test_BaseURI() public {
        assertEq(
            erc721uniforge.baseURI(),
            "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/"
        );
    }

    function test_TokenURI() public {
        vm.prank(minter);
        erc721uniforge.mintNft{value: 1e16}(1);
        console.log(erc721uniforge.totalSupply());
        assertEq(erc721uniforge.totalSupply(), 1);
        assertEq(
            erc721uniforge.tokenURI(0),
            "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/0"
        );
    }

    function test_NotExistentTokenReturnsEmpty() public {
        vm.expectRevert();
        erc721uniforge.tokenURI(5);
    }
}
