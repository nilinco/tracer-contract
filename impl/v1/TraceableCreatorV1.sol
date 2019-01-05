pragma solidity ^0.5.0;

import "./TraceableV1.sol";
import "../../tracing/TraceableCreator.sol";


contract TraceableCreatorV1 is TraceableCreator {

    address _traceManager;

    constructor(address pm) public {
      _traceManager =  pm;
    }

    function create(uint256 tokenId, address owner ,string calldata _label
    ,string calldata _traceableType
    ,uint256 _quantity, bool _partiallyTransferEnabled) external returns (Traceable) {
       return new TraceableV1(tokenId, owner, _label, _traceableType, _quantity, _partiallyTransferEnabled);
    }

    function traceManager() external view returns (address) {
       return _traceManager;
    }
}
