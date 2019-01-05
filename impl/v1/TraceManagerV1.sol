pragma solidity ^0.5.0;

import "../../lib/SafeMath.sol";
import "../../lib/AddressUtil.sol";
import "../../tracing/TraceableCreator.sol";
import "../../tracing/TraceManager.sol";
import "../../tracing/Traceable.sol";

contract TraceManagerV1 is TraceManager {
    using SafeMath for uint256;
    using AddressUtil for address;

    // Mapping from token ID to owner
    mapping(uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to number of owned token
    mapping(address => uint256) private _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Mapping from token ID to product
    mapping(uint256 => Traceable) private _tokenProducts;

    mapping(string => uint256) private _tokenLabels;


    uint256 private _lastTokenId;

    TraceableCreator _traceableCreator;

    address _dataGenerator;


    constructor () public {

    }

    function setTraceableCreator(address creator) external {
       require(TraceableCreator(creator).traceManager() == address(this));
       _traceableCreator = TraceableCreator(creator);
    }

    function setDataGenerator(address dataGenerator) external {
        _dataGenerator = dataGenerator;
    }

    function getDataGenerator() public view returns (address) {
       return _dataGenerator;
    }


    function ownerOf(string memory _label) public view returns (address) {
        uint256 tokenId = _tokenLabels[_label];
        address owner = _tokenOwner[tokenId];
        require(owner != address(0));
        return owner;
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0));
        return owner;
    }


    function approve(address to, string calldata _label) external {
        uint256 tokenId = _tokenLabels[_label];
        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }


    function getApproved(string memory _label) public view returns (address) {
        uint256 tokenId = _tokenLabels[_label];
        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }


    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }


    function setApprovalForAll(address to, bool approved) external {
        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }


    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transfer(address _to, string calldata _label, bool _partialTransferEnabled) external {
       _transferFrom(msg.sender, _to, _label,  _partialTransferEnabled);
    }

    function transferFrom(address _from, address _to, string calldata _label, bool _partialTransferEnabled) external {
      _transferFrom(_from, _to, _label,  _partialTransferEnabled);
    }

    function _transferFrom(address _from, address _to, string memory _label, bool _partialTransferEnabled) internal {
        uint256 tokenId = _tokenLabels[_label];
        require(_isApprovedOrOwner(msg.sender, tokenId));
        require(ownerOf(tokenId) == _from);
        require(_to != address(0));
        Traceable old = _tokenProducts[tokenId];
        require(old.quantity() > 0 );
        _clearApproval(tokenId);
        _tokenOwner[tokenId] = address(0);
        _ownedTokensCount[_from] = _ownedTokensCount[_from].sub(1);
        _ownedTokensCount[_to] = _ownedTokensCount[_to].add(1);
        _lastTokenId = _lastTokenId.add(1);
        uint256 newTokenId = _lastTokenId;
        _tokenOwner[newTokenId] = _to;
        _tokenLabels[_label] = newTokenId;
        Traceable p = _traceableCreator.create(newTokenId, address(old), _label, old.traceableType(), old.quantity(), _partialTransferEnabled);
        _tokenProducts[newTokenId] = p;
        old.transfer(newTokenId);
        emit Transfer(_from, _to, _label, tokenId, newTokenId, old.quantity());
    }


    function partialTransferFrom(address _from, address _to, string calldata _label, string calldata _newLabel
                                , uint256 _quantity, bool _partialTransferEnabled) external {
        uint256 tokenId = _tokenLabels[_label];
        require(_isApprovedOrOwner(msg.sender, tokenId));
        require(ownerOf(tokenId) == _from);
        require(_to != address(0));
        Traceable old = _tokenProducts[tokenId];
        require(old.quantity() >= _quantity );
        if ( old.quantity() == _quantity ){
            _tokenOwner[tokenId] = address(0);
            _ownedTokensCount[_from] = _ownedTokensCount[_from].sub(1);
        } else {

        }
        _ownedTokensCount[_to] = _ownedTokensCount[_to].add(1);
        _lastTokenId = _lastTokenId.add(1);
        uint256 newTokenId = _lastTokenId;
        _tokenOwner[newTokenId] = _to;
        _tokenLabels[_newLabel] = newTokenId;
         Traceable p = _traceableCreator.create(newTokenId, address(old), _newLabel, old.traceableType(), _quantity, _partialTransferEnabled);
        _tokenProducts[newTokenId] = p;
         old.partiallyTransfer(newTokenId,  _quantity);
         emit Transfer(_from, _to, _label, tokenId, newTokenId, _quantity);
    }

    function aggragate(address _from, string calldata _holder
                            , string calldata _content
                            , uint256 _quantity ) external {
        uint256 holderTokenId = _tokenLabels[_holder];
        require( ownerOf(holderTokenId) == _from);
        require( _isApprovedOrOwner(msg.sender, holderTokenId));
        uint256 contentTokenId = _tokenLabels[_content];
        require( ownerOf(contentTokenId) == _from);
        require( _isApprovedOrOwner(msg.sender, contentTokenId));
        Traceable holderTraceable = _tokenProducts[holderTokenId];
        Traceable contentTraceable = _tokenProducts[contentTokenId];
        require( contentTraceable.quantity() >= _quantity );
        contentTraceable.addHolder(holderTokenId, _quantity);
        holderTraceable.addContent(contentTokenId, _quantity);
        emit Aggregate(_from, holderTokenId, contentTokenId, _quantity);
    }


    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function isApprovedOrOwner(address spender, uint256 tokenId) external view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }


    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        // Disable solium check because of
        // https://github.com/duaraghav8/Solium/issues/175
        // solium-disable-next-line operator-whitespace
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }


    function mint(address _owner, string calldata _label, string calldata _traceableType, uint256 _quantity, bool _partiallyTransferEnabled) external{
        require(_owner != address(0));
        require(_tokenLabels[_label] == 0);
        _lastTokenId = _lastTokenId.add(1);
         uint256 newTokenId = _lastTokenId;
        _tokenOwner[newTokenId] = _owner;
        _ownedTokensCount[_owner] = _ownedTokensCount[_owner].add(1);
        _tokenLabels[_label] = newTokenId;
         Traceable p = _traceableCreator.create(newTokenId, address(0), _label, _traceableType, _quantity, _partiallyTransferEnabled);
        _tokenProducts[newTokenId] = p;
        emit Transfer(msg.sender, _owner, _label, 0, newTokenId, _quantity);
    }


    function burn(address from, string calldata _label, uint256 _quantity) external{
        uint256 tokenId = _tokenLabels[_label];
        require(_isApprovedOrOwner(msg.sender, tokenId));
        require(ownerOf(tokenId) == from);
        Traceable old = _tokenProducts[tokenId];
        require(old.quantity() >= _quantity );
        if ( old.quantity() == _quantity ){
            _tokenOwner[tokenId] = address(0);
            _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);
        } else {

        }
        old.burn( _quantity);
        emit Transfer(from, address(0), _label, tokenId, tokenId, _quantity);
    }




    /**
     * @dev Private function to clear current approval of a given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }

    function getTraceable(string calldata _label) view external returns(Traceable){
       uint256 tokenId = _tokenLabels[_label];
       return _tokenProducts[tokenId];
    }

    function getTraceable(uint256 tokenId) view external returns(Traceable){
        return _tokenProducts[tokenId];
    }


}
