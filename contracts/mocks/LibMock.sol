pragma solidity ^0.4.24;

import "../ERC677Lib.sol";


contract LibMock {

  function isContract(address addr) public view returns (bool) {
    return ERC677Lib.isContract(addr);
  }

}
