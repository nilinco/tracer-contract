pragma solidity ^0.5.0;

import "./Traceable.sol";
contract TraceableCreator {
   function create(uint256 newTokenId, address owner, string calldata _label
                    , string calldata _traceableType
                    , uint256 _quantity
                    , bool _partiallyTransferEnabled) external returns (Traceable);
   function traceManager() external view returns(address);
}
