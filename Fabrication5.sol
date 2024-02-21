// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Receive Function
// Un Smart Contract que permite recibir dinero como lo hace un EOA

contract Fabrication {
    uint256 public units;
    address payable public owner;
    
    constructor(uint256 initialUnits) {
        owner = payable (msg.sender);
        units = initialUnits;
    }

    modifier isOwner() {
        require(msg.sender == owner, "You are not the owner of this contract instance");
        _;
    }

    function setUnits(uint256 newUnits) external isOwner {
        units = newUnits;
        
    }

    function balance () public view returns (uint256){
        return address(this).balance;

    }

    function incrementUnits(uint256 increment) external payable{
        require(msg.value == 1 ether * increment, "not enought ether" );
        units = units + increment;
    }

    function widthdraw() isOwner external {
        owner.transfer(balance());
    }

    receive() external payable { }
}
