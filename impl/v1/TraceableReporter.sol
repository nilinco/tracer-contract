pragma solidity ^0.5.0;

import "../../lib/SafeMath.sol";
import "../../lib/AddressUtil.sol";
import "../../tracing/Traceable.sol";
import "../../tracing/TraceManager.sol";

contract TraceableReporter {

    constructor() public {

    }

    function report(address tm, string calldata label, bool brief) external view returns (string memory){
       TraceManager traceManager = TraceManager(tm);
       Traceable traceable = traceManager.getTraceable(label);
       Traceable[] memory chain = new Traceable[](traceable.chainLength());
       if ( !brief ){
            Traceable loopItem = traceable;
            for(uint i = traceable.chainLength(); i > 0; i-- ){
                chain[i] = loopItem;
                loopItem = loopItem.genesis();
            }
            return chain[0].label();
       } else {
          return traceable.label();
       }
    }
}
