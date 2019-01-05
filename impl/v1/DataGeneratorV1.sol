pragma solidity ^0.5.0;

import "../../lib/Strings.sol";
import "../../tracing/DataGenerator.sol";

contract DataGeneratorV1 is DataGenerator {
    using Strings for *;

    constructor() public {

    }

    function createRandomId(string memory dtype, string memory dtag) public view returns (string memory id){
        string memory ret = (block.number.toString());
        ret = ret.toSlice().concat(dtype.toSlice());
        ret = ret.toSlice().concat(dtag.toSlice());
        return ret;
    }

    function appendData(string memory data, string memory adata) public view returns (string memory newData){
       string memory ret = data;
       ret = ret.toSlice().concat(adata.toSlice());
       return ret;
    }

    function appendIntData(string memory data, uint256 adata) public view returns (string memory newData){
        string memory ret = data;
        ret = ret.toSlice().concat(adata.toString().toSlice());
        return ret;
    }

    function appendAddressData(string memory data, address adata) public view returns (string memory newData){
        string memory ret = data;
        ret = ret.toSlice().concat(adata.toString().toSlice());
        return ret;
    }

    function appendBytesData(string memory data, bytes32 adata) public view returns (string memory newData){
        string memory ret = data;
        ret = ret.toSlice().concat(adata.toSliceB32());
        return ret;
    }

}
