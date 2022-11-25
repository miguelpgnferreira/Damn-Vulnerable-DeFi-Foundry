// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/src-default/naive-receiver/NaiveReceiverLenderPool.sol";
import "src/src-default/naive-receiver/FlashLoanReceiver.sol";

import "src/src-default/DamnValuableToken.sol";

import "forge-std/Test.sol";

contract NaiveReceiverFixture is Test {
    //
    // Constants
    //
    uint256 public constant ETHER_IN_POOL = 1000 ether;
    uint256 public constant ETHER_IN_RECEIVER = 10 ether;

    //
    // Clueless contracts
    //
    NaiveReceiverLenderPool public pool;
    FlashLoanReceiver public receiver;

    // Attacker address
    address public attacker = vm.addr(1500);
    // Deployer address
    address public deployer = vm.addr(1501);
    // Random user address
    address public user = vm.addr(1502);

    function setUp() public virtual {
        // Label addresses
        vm.label(attacker, "Attacker");
        vm.label(deployer, "Deployer");

        // Fund deployer wallet
        vm.deal(deployer, 1010 ether);

        vm.startPrank(deployer);

        // Deploy Safe Receiver contracts
        pool = new NaiveReceiverLenderPool();
        receiver = new FlashLoanReceiver(payable(address(pool)));

        // Fund pool with initial balance
        payable(address(pool)).transfer(ETHER_IN_POOL);

        // Sanity check
        assertEq(address(pool).balance, ETHER_IN_POOL);
        assertEq(pool.fixedFee(), 1 ether);

        // Fund receiver with initial balance
        payable(address(receiver)).transfer(ETHER_IN_RECEIVER);

        // Sanity check
        assertEq(address(receiver).balance, ETHER_IN_RECEIVER);

        vm.stopPrank();
    }
}
