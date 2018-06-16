// Interface for ERC20 Token Standard
pragma solidity ^0.4.0;

interface ERC20{

  // @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
  // @param _from The address of the sender
  // @param _to The address of the recipient
  // @param _value The amount of token to be transferred
  // @return Whether the transfer was successful or not
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

  // @notice `msg.sender` approves `_spender` to spend `_value` tokens
  // @param _spender The address of the account able to transfer the tokens
  // @param _value The amount of tokens to be approved for transfer
  // @return Whether the approval was successful or not
  function approve(address _spender, uint256 _value) public returns (bool);

  // @param _owner The address of the account owning tokens
  // @param _spender The address of the account able to transfer the tokens
  // @return Amount of remaining tokens allowed to spent
  function allowance(address _owner, address _spender) public constant returns (uint256);

  event Approval(address _from, address _to, uint256 _value);
}

interface ERC223{
  // @notice send `_value` token to `_to` from `msg.sender`
  // @param _to The address of the recipient
  // @param _value The amount of token to be transferred
  // @param _data The data associated with the transaction
  // @return Whether the transfer was successful or not
  function transfer(address _to, uint256 _value, bytes _data) public returns (bool);

  event Transfer(address _from, address _to, uint256 _value, bytes _data);
}


contract StandardToken{

  // Token identities
  string internal _name;
  string internal _symbol;
  uint8 internal _decimels;
  uint256 internal _totalSupply;

  // Mapping to store addresses and balances
  mapping (address => uint256) internal _balanceOf;

  // Nested Mapping to store allowances
  mapping (address => mapping (address => uint256)) internal _allowance;

  function StandardToken(string name, string symbol, uint8 decimels, uint256 totalSupply) internal{
      _name = name;
      _symbol = symbol;
      _decimels = decimels;
      _totalSupply = totalSupply;
  }

  // Getter functions for contract data fields
  function name() public constant returns (string){
    return _name;
  }

  function symbol() public constant returns (string){
    return _symbol;
  }

  function decimels() public constant returns (uint8){
    return _decimels;
  }

  function totalSupply() public constant returns (uint256){
    return _totalSupply;
  }

  // The constant keyword is replaced by view in this interface.
  // @param _owner The address from which the balance will be retrieved
  // @return The balance
  function balanceOf(address _owner) public constant returns (uint256);

  function transfer(address _to, uint _value) public returns (bool);
  event Transfer(address indexed _from, address indexed _to, uint _value);
}

contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint _value, bytes _data) public;
}


library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract P2PToken is StandardToken("P2P Token", "P2P", 18, 10000), ERC20, ERC223{

  using SafeMath for uint256;

  // MaxLimit of uint256
  uint256 private MAX_LIMIT = 2**256-1;

  function P2PToken() public{
    _balanceOf[msg.sender] = _totalSupply;
  }

  function balanceOf(address _owner) public constant returns (uint256){
    return _balanceOf[_owner];
  }

  function transfer(address _to, uint256 _value) public returns (bool){
    if (_balanceOf[msg.sender] >= _value && _value>0 && !isContract(_to) && _allowance[msg.sender][_to] >= _value){
        _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);
        _balanceOf[_to] = _balanceOf[_to].add(_value);
        _allowance[msg.sender][_to] = _allowance[msg.sender][_to].sub(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    return false;
  }

  function transfer(address _to, uint256 _value, bytes _data) public returns (bool){
      if (_value > 0 && _balanceOf[msg.sender] >= _value && isContract(_to)){
        _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);
        _balanceOf[_to] = _balanceOf[_to].add(_value);
        _allowance[msg.sender][_to] = _allowance[msg.sender][_to].sub(_value);
        ERC223ReceivingContract _contract = ERC223ReceivingContract(_to);
        _contract.tokenFallback(msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value);
        return true;
      }
      return false;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
    uint allowedLimit = _allowance[_from][msg.sender];
    if (_balanceOf[_from] >= _value && allowedLimit >= _value && allowedLimit < MAX_LIMIT){
        _balanceOf[_from] = _balanceOf[_from].sub(_value);
        _balanceOf[_to] = _balanceOf[_to].add(_value);
        _allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }
    return false;
  }

  function approve(address _spender, uint256 _value) public returns (bool){
    _allowance[msg.sender][_spender] = _allowance[msg.sender][_spender].add(_value);
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint256){
    return _allowance[_owner][_spender];
  }

  function isContract(address _address) public view returns (bool){
      uint256 codeLength;
      assembly{
          codeLength := extcodesize(_address)
      }
      return codeLength > 0;
  }
}
