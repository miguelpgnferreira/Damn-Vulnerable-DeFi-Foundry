// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

import "src/src-default/DamnValuableToken.sol";
import "src/src-default/the-rewarder/TheRewarderPool.sol";
import "src/src-default/the-rewarder/RewardToken.sol";
import "src/src-default/the-rewarder/AccountingToken.sol";
import "src/src-default/the-rewarder/FlashLoanerPool.sol";

contract TheRewarderFixture is Test {
    //
    // Constants
    //
    uint256 public constant TOKENS_IN_LENDER_POOL = 1_000_000e18;
    uint256 public constant USER_DEPOSIT = 100e18;

    //
    // Pool contracts
    //
    FlashLoanerPool public flashLoanerPool;
    TheRewarderPool public theRewarderPool;

    //
    // Token contract
    //
    DamnValuableToken public token;

    //
    // User addresses
    //
    address payable[] public users;
    address payable public user1;
    address payable public user2;
    address payable public user3;
    address payable public user4;

    // Attacker address
    address payable public attacker;
    // Deployer address
    address public deployer = vm.addr(1501);

    function setUp() public virtual {
        // Create users
        users = createUsers(5);

        user1 = users[0];
        user2 = users[1];
        user3 = users[2];
        user4 = users[3];
        attacker = users[4];

        // Label user addresses
        vm.label(user1, "user1");
        vm.label(user2, "user2");
        vm.label(user3, "user3");
        vm.label(user4, "user4");
        vm.label(attacker, "Attacker");

        vm.startPrank(deployer);

        // Setup token contract
        token = new DamnValuableToken();
        vm.label(address(token), "DVT");

        // Setup pool contract
        flashLoanerPool = new FlashLoanerPool(address(token));
        vm.label(address(flashLoanerPool), "Flash Loaner Pool");
        token.transfer(address(flashLoanerPool), TOKENS_IN_LENDER_POOL);

        theRewarderPool = new TheRewarderPool(address(token));

        vm.stopPrank();

        // user1, user2, user3 and user4 deposit 100 tokens each
        for (uint8 i; i < 4; i++) {
            vm.prank(deployer);
            token.transfer(users[i], USER_DEPOSIT);
            vm.startPrank(users[i]);
            token.approve(address(theRewarderPool), USER_DEPOSIT);
            theRewarderPool.deposit(USER_DEPOSIT);
            assertEq(theRewarderPool.accToken().balanceOf(users[i]), USER_DEPOSIT);
            vm.stopPrank();
        }

        // Sanity check
        assertEq(theRewarderPool.accToken().totalSupply(), USER_DEPOSIT * 4);
        assertEq(theRewarderPool.rewardToken().totalSupply(), 0);

        // Advance time 5 days so that depositors can get awards
        vm.warp(block.timestamp + 5 days); // 5 days

        for (uint8 i; i < 4; i++) {
            vm.prank(users[i]);
            theRewarderPool.distributeRewards();
            assertEq(
                theRewarderPool.rewardToken().balanceOf(users[i]),
                25e18 // Each depositor gets 25 award tokens
            );
        }

        // Sanity check
        assertEq(theRewarderPool.rewardToken().totalSupply(), 100e18);
        assertEq(token.balanceOf(attacker), 0);
        assertEq(theRewarderPool.roundNumber(), 2);
    }

    //
    // Helper functions
    //
    bytes32 public nextUser = keccak256(abi.encodePacked("user address"));

    function getNextUserAddress() public returns (address payable) {
        //bytes32 to address conversion
        address payable user = payable(address(uint160(uint256(nextUser))));
        nextUser = keccak256(abi.encodePacked(nextUser));
        return user;
    }

    function createUsers(uint256 userNum) public returns (address payable[] memory) {
        users = new address payable[](userNum);
        for (uint256 i = 0; i < userNum; i++) {
            address payable user = this.getNextUserAddress();
            vm.deal(user, 100 ether);
            users[i] = user;
        }
        return users;
    }
}
