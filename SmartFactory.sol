// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract SmartFactory {
    //Storage and Definition
    address[] public owners;

    mapping(address => bool) public votes;

    // Produccion propuesta
    struct ProposalData {
        uint256 units;
        uint256 activationPeriod;
        uint256 registrationTimestamp;
    }

    // Produccion actual
    struct CurrentData {
        uint256 units;
        uint256 activationTimestamp;
    }

    // Produccion anterior o previo a la aceptacion de la nueva propuesta
    struct PreviousData {
        uint256 units;
    }

    ProposalData public proposalData;
    CurrentData public currentData;
    PreviousData public previousData;

    uint256 ATTEMPT_PERIOD = 60;

    //Logic

    // para desplegar el contrato tengo que enviar una tx con dinero
    constructor(address payable[] memory _owners, uint256 initialUnits) {
        owners = _owners;
        previousData = PreviousData(initialUnits);
        currentData = CurrentData(initialUnits, block.timestamp);
    }

    // funcion votar, solo los owners pueden votar

    modifier onlyOwners() {
        bool isOwner;
        for (uint256 i = 0; i < owners.length; i++) {
            if (msg.sender == owners[i]) {
                isOwner = true;
                break;
            }
        }
        require(isOwner == true, "You are not an owner");
        _;
    }

    function vote(uint256 _units, uint256 _activationPeriod) public onlyOwners {
        uint256 votingCount;
        require(votes[msg.sender] == false); // requiero que el owner que votara no voto previamente
        require(_units > 0);
        require(
            _units == proposalData.units &&
                _activationPeriod == proposalData.activationPeriod
        ); // validar que se voten por la unidades de la propuesta actual

        //contando los votos
        for (uint256 i = 0; i < owners.length; i++) {
            if (votes[owners[i]]) {
                votingCount++;
            }
        }

        //si ya se obtuvo mayoria se cierra la votacion
        if (++votingCount > owners.length / 2) {
            previousData.units = currentData.units;
            currentData = CurrentData(
                proposalData.units,
                block.timestamp + proposalData.activationPeriod
            );
            proposalData = ProposalData(0, 0, 0); // como la propuesta ya esta aceptada reinicio la variable para nuevas propuestas
        } else {
            //votando por una propuesta
            votes[msg.sender] = true;
        }
    }

    // funcion que retorna las unidades a producir actual
    function units() public view returns (uint256) {
        return
            (block.timestamp > currentData.activationTimestamp)
                ? currentData.units
                : previousData.units;
    }


    // Function to create a new proposal
    function newProposal(uint256 _units, uint256 _activationPeriod)
        public
        onlyOwners
    {
        require(
            block.timestamp > currentData.activationTimestamp,
            "Cannot propose, there is a pending activation"
        );
        require(_units > 0);
        require(
            _units != proposalData.units ||
                _activationPeriod != proposalData.activationPeriod,
            "Cannot propose, need diff prop"
        );
        require(
            (block.timestamp >
                proposalData.registrationTimestamp + ATTEMPT_PERIOD) ||
                proposalData.units == 0,
            "Cannot propose"
        );
        for (uint256 i = 0; i < owners.length; i++) {
            if (msg.sender != owners[i]) {
                votes[owners[i]] = false;
            } else if (votes[owners[i]] == false) {
                votes[owners[i]] = true;
            } // we avoid resetting to true the proposer vote
        }
        proposalData = ProposalData(_units, _activationPeriod, block.timestamp);
    }
}
