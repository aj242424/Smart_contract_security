// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

// Library Contract
contract SafeLib {
    address public owner;

    function takeOwnership() public {
        owner = msg.sender;
    }
}

// Safe Vulnerable Contract
contract SafeVulnerableContract {
    address public owner;
    SafeLib public lib;

    constructor(SafeLib _lib) {
        owner = msg.sender;
        lib = SafeLib(_lib);
    }

    // Fallback function with access control
    fallback() external payable {
        require(msg.sender == owner, "Caller is not the owner");
        (bool result, ) = address(lib).delegatecall(msg.data);
        require(result, "Lib call failed");
    }
}

// Attacker Contract
contract SafeAttackerContract {
    SafeVulnerableContract public vulnerableContract;

    constructor(SafeVulnerableContract _vulnerableContract) {
        vulnerableContract = _vulnerableContract;
    }

    // Attempt to perform attack
    function attack() public {
        (bool result, ) = address(vulnerableContract).call(abi.encodeWithSignature("takeOwnership()"));
        require(result, "Failed to take ownership");
    }
}

