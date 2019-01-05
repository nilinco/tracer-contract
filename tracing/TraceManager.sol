pragma solidity ^0.5.0;

import "./Traceable.sol";

contract TraceManager {

    function ownerOf(string memory _label) public view returns (address);

    function ownerOf(uint256 tokenId) public view returns (address);

    function transferFrom(address _from, address _to, string calldata _label, bool newProductPartiallyTransferable) external;

    function partialTransferFrom(address _from, address _to, string calldata _label, string calldata _newLabel, uint256 _quantity, bool partialTransferEnabled) external;

    function mint(address _owner, string calldata _label, string calldata traceableType, uint256 _quantity, bool partialTransferEnabled) external;

    function approve(address _approved, string calldata _label) external;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(string memory _label) public view returns (address);

    function isApprovedForAll(address _owner, address _operator) public view returns (bool);

    function getTraceable(string calldata _label) external view returns(Traceable);

    function getTraceable(uint256 tokenId) external view returns(Traceable);

    function isApprovedOrOwner(address spender, uint256 tokenId) external view returns (bool);

    function getDataGenerator() public view returns(address);

    //events
    event Transfer(address indexed _from, address indexed _to, string indexed _label, uint256 _tokenId, uint256 _newTokenId,  uint256 _quantity);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event Aggregate(address indexed _owner, uint256 indexed _holderTokenId, uint256 indexed _contentTokenId, uint256 _quantity);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

}

