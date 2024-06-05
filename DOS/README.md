# Smart_contract_security
```bash
;
```
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

let us go to the function _becomeKing() internal
Suppose a participant sent ether > = prize and becomes the new king ,
This function  _becomeKing() will first checks if the sent Ether is at least the current prize, transfers the Ether to the current king, and updates the king and prize.send ether to the current king.

The vulnerability lies in the king.transfer(msg.value) line. If the king is a contract that reverts on receiving Ether, the transfer will fail, causing a Denial of Service.
