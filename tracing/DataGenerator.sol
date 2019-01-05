pragma solidity ^0.5.0;

contract DataGenerator {
    function createRandomId(string memory dtype, string memory dtag) public view returns (string memory id);
    function appendData(string memory data, string memory adata) public view returns (string memory newData);
    function appendIntData(string memory data, uint256 adata) public view returns (string memory newData);
    function appendAddressData(string memory data, address adata) public view returns (string memory newData);
    function appendBytesData(string memory data, bytes32 adata) public view returns (string memory newData);
}
