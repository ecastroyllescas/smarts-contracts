// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// More Governance (with a Mapping)
// A version of admins with an Mapping
contract Fabrication {
    uint256 public units;
    address public owner;
    mapping(address=>bool) public admins;
    uint256 public numberOfAdmins;
    
    constructor(uint256 initialUnits) {
        owner = msg.sender;
        units = initialUnits;
    }

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier isAuthorized() {
        require(msg.sender==owner || admins[msg.sender] == true);
        _;
    }

    function setUnits(uint256 newUnits) external isAuthorized {
        units = newUnits;
    }

    function incrementUnits(uint256 increment) external isAuthorized {
        units = units + increment;
    }

    function addAdmin(address newAdmin) external isOwner {
        admins[newAdmin]=true;
        numberOfAdmins++;
    }

    function removeAdmin(address adminToDelete) external isOwner {
        admins[adminToDelete] = false;
        numberOfAdmins--;
    }

    function removeOwner() isOwner public {
        admins[owner]=true; // adicionando el owner a la lista de admins
        owner = address(0);
    }
}
