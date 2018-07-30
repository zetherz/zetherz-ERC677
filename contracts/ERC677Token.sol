pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "zetherz-ERC223/contracts/ERC223Token.sol";
import "./ERC677Contract.sol";


// implements ERC677
// see: https://github.com/ethereum/EIPs/issues/677
contract ERC677Token is ERC677Contract, ERC223Token, StandardToken {

  // Approves and then calls the receiving contract
  function approveAndCall(address _to, uint256 _value, bytes _data) public returns (bool success) {
    super.approve(_to, _value); // StandardToken

    require(
      ERC677Contract(_to).receiveApproval(msg.sender, _value, address(this), _data),
      "receiveApproval failed"
    );

    return true;
  }

  // Transfers and then calls the receiving contract
  function transferAndCall(address _to, uint256 _value, bytes _data) public returns (bool success) {
    super.transfer(_to, _value, _data); // ERC223Token

    require(
      ERC677Contract(_to).receiveTransfer(msg.sender, _value, address(this), _data),
      "receiveTransfer failed"
    );

    return true;
  }

}
