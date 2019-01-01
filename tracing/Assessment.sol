pragma solidity ^0.5.0;

contract Assessment {
    function evaluator() external view returns (address);
    function data() external view returns (string memory);
    function hash() external view returns (string memory);
    function tokenId() external view returns (uint256);
}
