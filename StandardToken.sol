// Implementation of StandardToken
pragma solidity ^0.4.24;

import "ERC20.sol";
import "ERC223.sol";

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

  constructor (string name, string symbol, uint8 decimels, uint256 totalSupply) internal{
      _name = name;
      _symbol = symbol;
      _decimels = decimels;
      _totalSupply = totalSupply;
  }

  // Getter functions for contract data fields
  function name() public view returns (string){
    return _name;
  }

  function symbol() public view returns (string){
    return _symbol;
  }

  function decimels() public view returns (uint8){
    return _decimels;
  }

  function totalSupply() public view returns (uint256){
    return _totalSupply;
  }

  // The constant keyword is replaced by view in this interface.
  // @param _owner The address from which the balance will be retrieved
  // @return The balance
  function balanceOf(address _owner) public view returns (uint256);

}
