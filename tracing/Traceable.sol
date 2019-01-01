pragma solidity ^0.5.0;

import "./Assessment.sol";

contract Traceable {

    function createTime() external view returns(uint256);

    function createBlock() external view returns(uint256);

    function rootCreateTime() external view returns(uint256);

    function rootCreateBlock() external view returns(uint256);

    function chainLength() external view returns(uint256); //ownership transfer chain length

    function label() external view returns (string memory label);

    function traceableType() external view returns (string memory);

    function genesis() external view returns (Traceable);

    function quantity() external view returns (uint256);

    function contentsOf() external view returns (Traceable[] memory);

    function contentsLength() external view returns (uint);

    function contentOf(uint256 tokenId) external view returns (Traceable, uint256);

    function contentAt(uint256 idx) external view returns (Traceable, uint256);

    function holdersOf() external view returns (Traceable[] memory);

    function holdersLength() external view returns (uint);

    function holderOf(uint256 tokenId) external view returns (Traceable, uint256);

    function holderAt(uint256 idx) external view returns (Traceable, uint256);

    function changesOf() external view returns (bytes32[] memory);

    function changesLength() external view returns (uint);

    function changeWithId(bytes32 eid) external view returns (bytes32 eventId,
                                                                      string memory eventType,
                                                                      string memory eventHash,
                                                                      string memory eventData,
                                                                      uint256 eventTime,
                                                                      uint256 eventBlock,
                                                                      address changedBy);
    function changesAt(uint index) external view returns (bytes32 eventId,
                                                                        string memory eventType,
                                                                        string memory eventHash,
                                                                        string memory eventData,
                                                                        uint256 eventTime,
                                                                        uint256 eventBlock,
                                                                        address changedBy);

    function rawMetadata()  external view returns (string memory);

    function hashMetadata()  external view returns (string memory);

    function setRawMetaData(string calldata raw)  external;

    function setHashMetaData(string calldata hash)  external;

    function addAssessment(Assessment assessment ) external;

    function assessments() external view returns (Assessment[] memory);

    function applyChange(bytes32 eventId
                        , string memory eventType
                        , string memory eventHash
                        , string memory eventData) public;

    function addContent(uint256 _contentTokenId
                        , uint256 quantity) public;

    function addHolder(uint256 _holderTokenId, uint256 _usedQuantity) public;

    function partiallyTransfer(uint256 newTokenId, uint256 quantity) public;

    function transfer(uint256 newTokenId) public;

    function burn(uint256 quantity) public;



    // Events
    event Change(bytes32 eventId
         , string eventType
         , string eventHash
         , string eventData
         , uint256 eventTime
         , uint256 eventBlock
         , address changedBy
         , uint256 _tokenId);

    event ContentAdded(uint256 _contentTokenId
    , uint256 quantity
    , uint256 eventTime
    , uint256 eventBlock
    , address addedBy
    , uint256 _tokenId);

    event ContentRemoved(uint256 _contentTokenId
    , uint256 quantity
    , uint256 eventTime
    , uint256 eventBlock
    , address addedBy
    , uint256 _tokenId);

    event HolderAdded(uint256 _holderTokenId
    , uint256 quantity
    , uint256 eventTime
    , uint256 eventBlock
    , address addedBy
    , uint256 _tokenId);

    event HolderRemoved(uint256 _holderTokenId
    , uint256 quantity
    , uint256 eventTime
    , uint256 eventBlock
    , address addedBy
    , uint256 _tokenId);


}
