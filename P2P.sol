// Implementation of P2P cryptocurrency
/* References
  https://github.com/ConsenSys/Tokens/blob/master/contracts/eip20/EIP20Interface.sol
  http://solidity.readthedocs.io/en/v0.4.24/ */

pragma solidity ^0.4.24;

import "ERC20Interface.sol";

contract P2P is ERC20TokenInterface{

  // MaxLimit of uint256
  uint private view MAX_LIMIT = 2**256-1;

  // Mapping to store addresses and balances
  mapping (address => uint256) public balances;

  // Nested Mapping to store allowances
  mapping (address => mapping (address => uint256)) public allowed;

  // Token identities
  string public view name = "Peer-to-Peer Coin";
  string public view symbol = "P2P";
  uint8 public view decimels = 18;

  // Token constructor
  function P2P(uint256 _totalSupply) public {
    totalSupply = _totalSupplyt;
    balances[msg.sender] = totalSupply;
  }

  function balanceOf(address _owner) public returns (uint256 balance){
    return balances[_owner];
  }

  function transfer(address _to, uint256 _value) public returns (bool success){
    require (balances[msg.sender] >= _value);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
    uint allowedLimit = allowed[_from][_to];
    require (balances[_from] >= _value && allowedLimit >= _value && allowedLimit < MAX_LIMIT);
    balances[_from] -= _value;
    balances[_to] += _value;
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool success){
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public returns (uint256 remaining){
    return allowed[_owner][_spender];
  }

}
