const { advanceBlock } = require('openzeppelin-solidity/test/helpers/advanceToBlock');

const LibMock = artifacts.require('LibMock');
const ERC677Token = artifacts.require('ERC677Token');

contract('ERC677Lib', function (accounts) {
  let lib;

  before(async function () {
    // Advance to the next block to correctly read time in the solidity "now" function interpreted by ganache
    await advanceBlock();

    lib = await LibMock.new();
  });

  it('should correctly check isContract', async function () {
    let contract = await ERC677Token.new();

    let isContractTrue = await lib.isContract.call(contract.address);
    assert.isTrue(isContractTrue);

    let isContractFalse = await lib.isContract.call(accounts[0]);
    assert.isFalse(isContractFalse);
  });
});
