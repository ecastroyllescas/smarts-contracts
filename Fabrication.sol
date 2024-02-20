pragma solidity ^0.8.0;

// A version of admins with an array
contract Fabrication {
    uint256 public units;
    address public owner;
    address[] public admins;

    constructor(uint256 initialUnits) {
        owner = msg.sender;
        units = initialUnits;
    }

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier isAuthorized() {
        bool isAdmin; // boolean variable
        for (uint256 i = 0; i < admins.length; i++) {
            if (msg.sender == admins[i]) {
                isAdmin = true;
                break;
            }
        }
        require(isAdmin == true || msg.sender == owner);
        _;
    }

    function setUnits(uint256 newUnits) external isAuthorized {
        units = newUnits;
    }

    function incrementUnits(uint256 increment) external isAuthorized {
        units = units + increment;
    }

    function addAdmin(address newAdmin) external isOwner {
        admins.push(newAdmin);
    }

    function removeAdmin(uint256 index) external isOwner {
        admins[index] = address(0);
    }

    function removeOwner() isOwner public {
        admins.push(owner); // adicionando el owner a la lista de admins
        owner = address(0);
    }
}

