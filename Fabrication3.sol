// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Blockchain ”Time”
// No se permiten cambios de unidades hasta por X dias
contract Fabrication {
    uint256 public units;
    address public owner;
    uint256 public period;
    uint256 public lastOrderTimestamp;
    
    constructor(uint256 initialUnits, uint256 _period) {
        owner = msg.sender;
        units = initialUnits;
        period = _period;
        lastOrderTimestamp = block.timestamp;
    }

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier isTimeOk(uint256 _period){
        require(block.timestamp > lastOrderTimestamp + _period);
        _;
        lastOrderTimestamp = block.timestamp;
    }

    function setUnits(uint256 newUnits) external isOwner isTimeOk(period*4) {
        units = newUnits;
        
    }

    function incrementUnits(uint256 increment) external isOwner isTimeOk(period*2) {
        units = units + increment;
    }


}
