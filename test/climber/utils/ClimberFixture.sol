// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/src-default/climber/ClimberTimelock.sol";
import "src/src-default/climber/ClimberVault.sol";

import "@openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";

import "src/src-default/DamnValuableToken.sol";

import "forge-std/Test.sol";

contract UUPSProxy is ERC1967Proxy {
    constructor(address _implementation, bytes memory _data) ERC1967Proxy(_implementation, _data) { }
}

contract ClimberFixture is Test {
    //
    // Constants
    //
    uint256 public constant VAULT_TOKEN_BALANCE = 10_000_000 * 10 ** 18;

    //
    // Contracts
    //
    ClimberVault public climberVaultImpl;
    UUPSProxy public climberVault;
    address timelockAddress;

    //
    // Token contract
    //
    DamnValuableToken public token;

    // Attacker address
    address public attacker = vm.addr(1500);
    // Admin address
    address public admin = vm.addr(1501);
    // Deployer address
    address public deployer = vm.addr(1502);
    // Proposer Address
    address public proposer = vm.addr(1503);
    // Sweeper Address
    address public sweeper = vm.addr(1504);

    function setUp() public virtual {
        // Label addresses
        vm.label(attacker, "Attacker");
        vm.label(deployer, "Deployer");
        vm.label(admin, "Admin");
        vm.label(proposer, "Proposer");
        vm.label(sweeper, "Sweeper");

        // Fund attacker address
        vm.deal(attacker, 0.1 ether);

        vm.startPrank(deployer);

        // Setup SecureVault implementation contract
        climberVaultImpl = new ClimberVault();

        // Setup Proxy contract
        bytes memory initializeData =
            abi.encodeWithSignature("initialize(address,address,address)", admin, proposer, sweeper);
        climberVault = new UUPSProxy(address(climberVaultImpl), initializeData);

        // Sanity checks
        (, bytes memory data) = address(climberVault).call(abi.encodeWithSignature("getSweeper()"));
        assertEq(abi.decode(data, (address)), sweeper);
        (, data) = address(climberVault).call(abi.encodeWithSignature("owner()"));
        timelockAddress = abi.decode(data, (address));
        assertTrue(timelockAddress != deployer && timelockAddress != address(0));
        (, data) = address(climberVault).call(abi.encodeWithSignature("getLastWithdrawalTimestamp()"));
        assertGt(abi.decode(data, (uint256)), 0);

        // Setup token contract
        token = new DamnValuableToken();

        // Transfer tokens
        token.transfer(address(climberVault), VAULT_TOKEN_BALANCE);

        // Sanity check
        assertEq(token.balanceOf(address(climberVault)), VAULT_TOKEN_BALANCE);

        vm.stopPrank();
    }
}
