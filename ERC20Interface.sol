// Abstarct contract for ERC20 Token Standard
/* References
  https://github.com/ConsenSys/Tokens/blob/master/contracts/eip20/EIP20Interface.sol
  http://solidity.readthedocs.io/en/v0.4.24/ */

pragma solidity ^0.4.24;

contract ERC20Interface{
  // Total amount of tokens
  uint256 public totalSupply;

  // The constant keyword is replaced by view in this interface.
  // @param _owner The address from which the balance will be retrieved
  // @return The balance
  function balanceOf(address _owner) public view returns (uint256 balance);

  // @notice send `_value` token to `_to` from `msg.sender`
  // @param _to The address of the recipient
  // @param _value The amount of token to be transferred
  // @return Whether the transfer was successful or not
  function transfer(address _to, uint256 _value) public returns (bool success);

  // @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
  // @param _from The address of the sender
  // @param _to The address of the recipient
  // @param _value The amount of token to be transferred
  // @return Whether the transfer was successful or not
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

  // @notice `msg.sender` approves `_spender` to spend `_value` tokens
  // @param _spender The address of the account able to transfer the tokens
  // @param _value The amount of tokens to be approved for transfer
  // @return Whether the approval was successful or not
  function approve(address _spender, uint256 _value) public returns (bool success);

  // @param _owner The address of the account owning tokens
  // @param _spender The address of the account able to transfer the tokens
  // @return Amount of remaining tokens allowed to spent
  function allowance(address _owner, address _spender) public view returns (uint256 remaining);


  event Transfer(address _from, address _to, uint256 _value);
  event Approval(address _from, address _to, uint256 _value);
}
