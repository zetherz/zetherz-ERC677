pragma solidity ^0.4.24;

import "./ERC677Lib.sol";


contract/* interface */ ERC677ContractInterface {
  function receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _data) public returns (bool);
  function receiveTransfer(address _from, uint256 _value, address _tokenContract, bytes _data) public returns (bool);
  event ReceiveApproval(address indexed from, uint256 value, address indexed tokenContract, bytes data);
  event ReceiveTransfer(address indexed from, uint256 value, address indexed tokenContract, bytes data);
}


// implements ERC677
// see: https://github.com/ethereum/EIPs/issues/677
contract ERC677Contract is ERC677ContractInterface {

  // Processes token approvals
  function receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _data) public returns (bool) {
    require(
      ERC677Lib.isContract(msg.sender),
      "receiveApproval must be called from a contract"
    );

    emit ReceiveApproval(_from, _value, _tokenContract, _data);

    return true;
  }

  // Processes token transfers
  function receiveTransfer(address _from, uint256 _value, address _tokenContract, bytes _data) public returns (bool) {
    require(
      ERC677Lib.isContract(msg.sender),
      "receiveTransfer must be called from a contract"
    );

    emit ReceiveTransfer(_from, _value, _tokenContract, _data);

    return true;
  }

}
