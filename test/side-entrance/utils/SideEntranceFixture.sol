// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/src-default/side-entrance/SideEntranceLenderPool.sol";

import "forge-std/Test.sol";

contract SideEntranceFixture is Test {
    //
    // Constants
    //
    uint256 public constant ETHER_IN_POOL = 1000 ether;

    uint256 public constant ATTACKER_INITIAL_BALANCE = 10 ether;

    //
    // Pool
    //
    SideEntranceLenderPool public pool;

    // Attacker address
    address public attacker = vm.addr(1500);
    // Deployer address
    address public deployer = vm.addr(1501);

    function setUp() public virtual {
        // Label addresses
        vm.label(attacker, "Attacker");
        vm.label(deployer, "Deployer");

        // Fund deployer wallet
        vm.deal(deployer, 1000 ether);
        // Fund attacker's wallet
        vm.deal(attacker, ATTACKER_INITIAL_BALANCE);

        vm.startPrank(deployer);

        // Setup Pool contract
        pool = new SideEntranceLenderPool();
        pool.deposit{value: ETHER_IN_POOL}();

        // Sanity check
        assertEq(address(pool).balance, ETHER_IN_POOL);

        vm.stopPrank();
    }
}
