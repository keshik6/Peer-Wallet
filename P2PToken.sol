pragma solidity ^0.4.24;

import "StandardToken.sol";

contract P2PToken is StandardToken("P2P Token", "P2P", 18, 10**27), ERC20, ERC223{

  // MaxLimit of uint256
  uint256 private MAX_LIMIT = 2**256-1;

  constructor () public{
    _balanceOf[msg.sender] = _totalSupply;
  }

  function balanceOf(address _owner) public view returns (uint256){
    return _balanceOf[_owner];
  }

  function transfer(address _to, uint256 _value) public returns (bool success){
    if (_balanceOf[msg.sender] >= _value && _value>0 && !isContract(_to) && _allowance[msg.sender][_to] >= _value){
        _balanceOf[msg.sender] -= _value;
        _balanceOf[_to] += _value;
        _allowance[msg.sender][_to] -= _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    return false;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
    uint allowedLimit = _allowance[_from][_to];
    if (_balanceOf[_from] >= _value && allowedLimit >= _value && allowedLimit < MAX_LIMIT){
        _balanceOf[_from] -= _value;
        _balanceOf[_to] += _value;
        _allowance[msg.sender][_to] -= _value;
         emit Transfer(_from, _to, _value);
        return true;
    }
    return false;
  }

  function approve(address _spender, uint256 _value) public returns (bool success){
    _allowance[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256 remaining){
    return _allowance[_owner][_spender];
  }

  function isContract(address _address) public view returns (bool){
      uint256 codeLength;
      assembly{
          codeLength := extcodesize(_address)
      }
      return codeLength > 0;
  }

  function transfer(address _to, uint256 _value, bytes _data) external returns (bool){
      if (_value > 0 && _balanceOf[msg.sender] >= _value && isContract(_to)){
        _balanceOf[msg.sender] -= _value;
        _balanceOf[_to] += _value;
        _allowance[msg.sender][_to] -= _value;
        ERC223ReceivingContract _contract = ERC223ReceivingContract(_to);
        _contract.tokenFallback(msg.sender, _value, _data);
        emit Transfer(msg.sender, _to, _value);
        return true;
      }
      return false;
  }
}
