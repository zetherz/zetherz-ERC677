pragma solidity ^0.4.24;

import "../ERC677Token.sol";


contract ERC677TokenMock is ERC677Token {

  constructor(address initialAccount, uint256 initialBalance) public {
    balances[initialAccount] = initialBalance;
    totalSupply_ = initialBalance;
  }

  // Accept ERC223 compatible tokens!
  function tokenFallback(address /*_from*/, uint256 /*_value*/, bytes /*_data*/) external {
  }

}
