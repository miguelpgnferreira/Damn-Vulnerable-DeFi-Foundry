// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/src-default/backdoor/WalletRegistry.sol";

import "@safe/contracts/GnosisSafe.sol";
import "@safe/contracts/proxies/GnosisSafeProxyFactory.sol";
import "src/src-default/DamnValuableToken.sol";

import "forge-std/Test.sol";

contract WalletRegistryFixture is Test {
    //
    // Constants
    //
    uint256 public constant AMOUNT_TOKENS_DISTRIBUTED = 40 ether;

    //
    // Safe contracts
    //
    GnosisSafe public masterCopy;
    GnosisSafeProxyFactory public walletFactory;

    //
    // Token contract
    //
    DamnValuableToken public token;

    //
    // Safe Registry
    //
    WalletRegistry public walletRegistry;

    // Attacker address
    address public attacker = vm.addr(1500);
    // Deployer address
    address public deployer = vm.addr(1501);
    // Initial beneficiaries for wallet
    address[] public users;
    address public alice = vm.addr(1502);
    address public bob = vm.addr(1503);
    address public charlie = vm.addr(1504);
    address public david = vm.addr(1505);

    function setUp() public virtual {
        // Label addresses
        vm.label(attacker, "Attacker");
        vm.label(deployer, "Deployer");

        // Fund deployer wallet
        vm.deal(deployer, 1000 ether);

        vm.startPrank(deployer);

        // Setup token contract
        token = new DamnValuableToken();

        // Setup Safe contracts
        masterCopy = new GnosisSafe();
        walletFactory = new GnosisSafeProxyFactory();

        // Deploy the Safe Registry
        users.push(alice);
        users.push(bob);
        users.push(charlie);
        users.push(david);
        walletRegistry = new WalletRegistry(
            address(masterCopy),
            address(walletFactory),
            address(token),
            users
        );

        // Ensure users were registered as beneficiaries
        for (uint256 i = 0; i < users.length; i++) {
            assertTrue(walletRegistry.beneficiaries(users[i]));
        }

        // Transfer tokens to be distributed
        token.transfer(address(walletRegistry), AMOUNT_TOKENS_DISTRIBUTED);

        vm.stopPrank();
    }
}
