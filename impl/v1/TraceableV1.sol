pragma solidity ^0.5.0;


import "../../tracing/Traceable.sol";
import "../../tracing/TraceManager.sol";
import "../../tracing/TraceableCreator.sol";
import "../../lib/SafeMath.sol";

contract TraceableV1 is Traceable {

    using SafeMath for uint256;

    uint256 _createTime;
    uint256 _createBlock;
    uint256 _rootCreateTime;
    uint256 _rootCreateBlock;
    uint256 _chainLength;
    address private _creator;
    address private _owner;
    string private _label;
    string private _traceableType;
    uint256 private _tokenId;
    uint256 private _quantity;
    bool private _partiallyTransferable;
    Traceable _genesis;
    uint256[] _contents;
    uint256[] _holders;
    ChangeEvent[] _changes;
    mapping(uint256 => Gradiant) _contentsMap;
    mapping(uint256 => Gradiant) _holdersMap;
    mapping(string => ChangeEvent) _changesMap;

    string private attribute; //for public data
    string private attributeHash; //for private data

    Assessment[] _assessments;
    mapping(address => Assessment) _assessmentsMap;
    bool _ready = false;

    constructor(uint256 tokenId
                , address genesisAddress
                , string memory label
                , string memory traceableType
                , uint256 quantity
                , bool partiallyTransferable) public {
        _creator = TraceableCreator(msg.sender).traceManager();
        _owner = TraceManager(_creator).ownerOf(tokenId);
        _genesis = TraceableV1(genesisAddress);
        _createBlock = block.number;
        _createTime = now;
        if ( genesisAddress != address(0) ) {
             _chainLength = _genesis.chainLength().add(1);
             _rootCreateTime = _genesis.rootCreateTime();
             _rootCreateBlock = _genesis.rootCreateBlock();
              attribute = _genesis.rawMetadata();
              attributeHash = _genesis.hashMetadata();
             uint256 cl = _genesis.contentsLength();
             for(uint i = 0; i < cl; i++ ){
                (Traceable t ,uint256 q)  = _genesis.contentAt(i);
                Gradiant memory gradiant = Gradiant({   item: t,
                                                        quantity: q,
                                                        exist: true
                                                        });
                _contentsMap[t.tokenId()] = gradiant;
                _contents.push(t.tokenId());
             }
        } else {
             _chainLength = 1;
             _rootCreateTime = _createTime;
             _rootCreateBlock = _createBlock;
        }
        _tokenId = tokenId;
        _traceableType = traceableType;
        _label = label;
        _quantity = quantity;
        _partiallyTransferable = partiallyTransferable;
    }

    modifier onlyOwner {
        require(msg.sender == _owner);
        _;
    }

    modifier onlyCreator {
        require(msg.sender == _creator);
        _;
    }

    modifier onlyAllowed {
      require(msg.sender == _creator || msg.sender == _owner
        || TraceManager(_creator).isApprovedOrOwner(msg.sender, _tokenId));
      _;
    }

    modifier onlyEvaluator {
        require(TraceManager(_creator).isApprovedOrOwner(msg.sender, _tokenId));
        //check msg.sender role to be evaluator
        _;
    }


    function partiallyTransfer(uint256 newTokenId
     , uint256 quantity
    ) public onlyCreator {
       require(_ready);
       require(_partiallyTransferable && quantity <= _quantity);
       require(TraceManager(_creator).getTraceable(newTokenId).quantity() == quantity);
       _quantity = _quantity.sub(quantity);
    }



    function transfer(uint256 newTokenId) public onlyCreator {
      require(_ready);
      require( _quantity > 0 && TraceManager(_creator).getTraceable(newTokenId).quantity() == _quantity);
      _quantity =  0;
    }



    function burn(uint256 quantity) public onlyCreator {
       require(_partiallyTransferable || _quantity < quantity);
       _quantity = _quantity.sub(quantity);
    }

    function markAsReady() public onlyAllowed {
       require(!_ready);
       _ready = true;
    }

    function applyChange(string memory _eventId
                        , string memory _eventType
                        , string memory _eventHash
                        , string memory _eventData) public onlyAllowed {
      ChangeEvent memory evnt = ChangeEvent({
                                                 eventId: _eventId,
                                                 eventType: _eventType,
                                                 eventHash: _eventHash,
                                                 eventData: _eventData,
                                                 eventTime: now,
                                                 eventBlock: block.number,
                                                 changedBy: msg.sender
                                            });
      _changesMap[_eventId] = evnt;
      _changes.push(evnt);
      emit Change( _eventId, _eventType,  _eventHash, _eventData, evnt.eventTime, evnt.eventBlock, evnt.changedBy, _tokenId );
    }

    function addContent(uint256 _contentTokenId
                        , uint256 _quantity) public onlyCreator {
        require(!_ready);
        if (  !_contentsMap[_contentTokenId].exist ) {
            Traceable content = TraceManager(_creator).getTraceable(_contentTokenId);
            Gradiant memory gradiant = Gradiant({  item: content,
                                                   quantity: _quantity,
                                                   exist: true
                                                 });
           _contentsMap[_contentTokenId] = gradiant;
           _contents.push(_contentTokenId);
        } else {
            Gradiant memory gradiant = _contentsMap[_contentTokenId];
            gradiant.quantity =  gradiant.quantity.add(_quantity);
            _contentsMap[_contentTokenId] = gradiant;
        }
        emit ContentChanged(_contentTokenId, int256(_quantity), now, block.number, msg.sender, _tokenId);
    }

    function addHolder(uint256 _holderTokenId, uint256 _usedQuantity) public onlyCreator {
         require(_ready);
         require( _usedQuantity <= _quantity );
        _quantity = _quantity.sub(_usedQuantity );
        if (  !_holdersMap[_holderTokenId].exist ) {
            Traceable holder = TraceManager(_creator).getTraceable(_holderTokenId);
            Gradiant memory gradiant = Gradiant({   item: holder,
                                                    quantity: _usedQuantity,
                                                    exist: true
                                                 });
            _holdersMap[_holderTokenId] = gradiant;
            _holders.push(_holderTokenId);
        } else {
            Gradiant memory gradiant = _holdersMap[_holderTokenId];
            gradiant.quantity =  gradiant.quantity.add(_usedQuantity);
            _holdersMap[_holderTokenId] = gradiant;
        }
        emit HolderChanged(_holderTokenId, int256(_usedQuantity), now, block.number, msg.sender, _tokenId);
    }


    function label() external view returns (string memory label){
        return _label;
    }

    function traceableType() external view returns (string memory){
        return _traceableType;
    }

    function partiallyTransferable() external view returns (bool){
        return _partiallyTransferable;
    }

    function quantity() external view returns (uint256){
        return _quantity;
    }

    function tokenId() external view returns (uint256){
       return _tokenId;
    }

    function genesis() external view returns (Traceable){
      return _genesis;
    }

    function owner() view public returns (address){
       return _owner;
    }

    function creator() view public returns (address){
       return _creator;
    }

    function chainLength() external view returns(uint256){
      return _chainLength;
    }

    function isReady() public view returns(bool){
        return _ready;
    }


    function contentsOf() external view returns (Traceable[] memory){
        Traceable[] memory ret = new Traceable[](_contents.length);
        for(uint i = 0; i < _contents.length; i++ ){
            ret[i] = _contentsMap[_contents[i]].item;
        }
        return ret;
    }

    function contentOf(uint256 tokenId) external view returns (Traceable, uint256){
        Gradiant memory g = _contentsMap[tokenId];
        return (g.item, g.quantity);
    }

    function contentAt(uint256 idx) external view returns (Traceable, uint256){
        Gradiant memory g = _contentsMap[_contents[idx]];
        return (g.item, g.quantity);
    }

    function contentsLength() external view returns (uint){
        return _contents.length;
    }

    function holdersOf() external view returns (Traceable[] memory) {
        Traceable[] memory ret = new Traceable[](_holders.length);
        for(uint i = 0; i < _holders.length; i++ ){
            ret[i] = _holdersMap[_holders[i]].item;
        }
        return ret;
    }

    function holderOf(uint256 tokenId) external view returns (Traceable, uint256){
        Gradiant memory g = _holdersMap[tokenId];
        return (g.item, g.quantity);
    }

    function holderAt(uint256 idx) external view returns (Traceable, uint256){
       Gradiant memory g = _holdersMap[_holders[idx]];
       return (g.item, g.quantity);
    }

    function holdersLength() external view returns (uint){
        return _holders.length;
    }

    function changesLength() external view returns (uint){
      return _changes.length;
    }

    function createTime() external view returns(uint256){
       return _createTime;
    }

    function createBlock() external view returns(uint256){
      return _createBlock;
    }

    function rootCreateTime() external view returns(uint256){
      return _rootCreateTime;
    }

    function rootCreateBlock() external view returns(uint256){
      return _rootCreateBlock;
    }

    function changeWithId(string calldata eid) external view returns (string memory eventId,
                                                                        string memory eventType,
                                                                        string memory eventHash,
                                                                        string memory eventData,
                                                                        uint256 eventTime,
                                                                        uint256 eventBlock,
                                                                        address changedBy){
        ChangeEvent storage ret = _changesMap[eid];
        return (ret.eventId, ret.eventType, ret.eventHash, ret.eventData, ret.eventTime, ret.eventBlock, ret.changedBy);
    }

    function changesAt(uint index) external view returns (string memory eventId,
                                                            string memory eventType,
                                                            string memory eventHash,
                                                            string memory eventData,
                                                            uint256 eventTime,
                                                            uint256 eventBlock,
                                                            address changedBy){
       ChangeEvent storage ret = _changes[index];
       return (ret.eventId, ret.eventType, ret.eventHash, ret.eventData, ret.eventTime, ret.eventBlock, ret.changedBy);

    }

    function rawMetadata()  external view returns (string memory){
        return attribute;
    }

    function hashMetadata()  external view returns (string memory){
        return attributeHash;
    }

    function setRawMetaData(string calldata raw)  external onlyAllowed {
       require(!_ready);
       attribute = raw;
    }

    function setHashMetaData(string calldata hash)  external onlyAllowed {
       require(!_ready);
       attributeHash = hash;
    }

    function addAssessment(Assessment assessment ) external onlyEvaluator {
      require(_ready);
      require(   address(_assessmentsMap[address(assessment)]) == address(0)
              && msg.sender == assessment.evaluator()
              && _tokenId == assessment.tokenId());
      _assessmentsMap[address(assessment)] = assessment;
      _assessments.push(assessment);
    }

    function assessments() external view returns (Assessment[] memory){
        Assessment[] memory ret = new Assessment[](_assessments.length);
        for(uint i = 0; i < _assessments.length; i++ ){
            ret[i] = _assessments[i];
        }
        return ret;
    }



    // Events
    event Change(string eventId
    , string eventType
    , string eventHash
    , string eventData
    , uint256 eventTime
    , uint256 eventBlock
    , address changedBy
    , uint256 _tokenId);

    event ContentChanged(uint256 _contentTokenId
    , int256 quantity
    , uint256 eventTime
    , uint256 eventBlock
    , address addedBy
    , uint256 _tokenId);

    event HolderChanged(uint256 _holderTokenId
    , int256 quantity
    , uint256 eventTime
    , uint256 eventBlock
    , address addedBy
    , uint256 _tokenId);

    struct ChangeEvent {
        string eventId;
        string eventType;
        string eventHash;
        string eventData;
        uint256 eventTime;
        uint256 eventBlock;
        address changedBy;
    }

    struct Gradiant {
       Traceable item;
       uint256 quantity;
       bool exist;
    }
}
