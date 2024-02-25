// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DIDRegistry {
    struct DIDDocument {
        address owner;
        string publicKey;
        string authenticationMethod;
        bool revoked;
        string CIC;
        // Other fields...
    }

    mapping(address => DIDDocument) public didDocuments;

    event DIDDocumentCreated(address indexed did, address indexed owner);

    modifier onlyOwner(address did) {
        require(didDocuments[did].owner == msg.sender, "Only the owner can perform this action");
        _;
    }

    function createDIDDocument(string memory publicKey, string memory authenticationMethod, string memory _CIC) external {
        require(bytes(publicKey).length > 0, "Public key is required");
        require(bytes(authenticationMethod).length > 0, "Authentication method is required");
        require(didDocuments[msg.sender].owner == address(0), "DID document already exists");

        didDocuments[msg.sender] = DIDDocument({
            owner: msg.sender,
            publicKey: publicKey,
            authenticationMethod: authenticationMethod,
            revoked : false,
            CIC : _CIC
            // Populate other fields...
        });

        emit DIDDocumentCreated(msg.sender, msg.sender);
    }

    function updateDIDDocument(string memory newPublicKey, string memory newAuthenticationMethod) external onlyOwner(msg.sender) {
        require(bytes(newPublicKey).length > 0, "New public key is required");
        require(bytes(newAuthenticationMethod).length > 0, "New authentication method is required");
        require(didDocuments[msg.sender].revoked == false, "DID document already revoked");

        DIDDocument storage doc = didDocuments[msg.sender];
        doc.publicKey = newPublicKey;
        doc.authenticationMethod = newAuthenticationMethod;
        // Update other fields...

        // Emit an event or perform additional actions as needed
    }

    function revokeDIDDocument() external onlyOwner(msg.sender) {
        require(didDocuments[msg.sender].revoked == false, "DID document already revoked");
        DIDDocument storage doc = didDocuments[msg.sender];
        doc.revoked = true;
        doc.publicKey = '0'; 
    }


    function getDIDDocument() external onlyOwner(msg.sender) view returns (DIDDocument memory){
        require(didDocuments[msg.sender].revoked == false, "DID document already revoked");
        return didDocuments[msg.sender];
    }


    // Other functions for resolving DIDs and additional features...
}