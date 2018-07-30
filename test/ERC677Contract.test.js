const { advanceBlock } = require('openzeppelin-solidity/test/helpers/advanceToBlock');
const { EVMRevert } = require('openzeppelin-solidity/test/helpers/EVMRevert');

require('chai')
  .use(require('chai-as-promised'))
  .should();

const ERC677Contract = artifacts.require('ERC677Contract');
const ERC677TokenMock = artifacts.require('ERC677TokenMock');

contract('ERC677Contract', function (accounts) {
  const value = 42;
  const dataCustom = '1337';

  let contract;
  let token;

  before(async function () {
    // Advance to the next block to correctly read time in the solidity "now" function interpreted by ganache
    await advanceBlock();

    contract = await ERC677Contract.new();
    token = await ERC677TokenMock.new(accounts[0], 1000, { from: accounts[0] });
  });

  it('should revert receiveApproval call from a non-contract', async function () {
    await contract.receiveApproval(accounts[0], value, token.address, dataCustom, { from: accounts[0] })
      .should.be.rejectedWith(EVMRevert);
  });

  it('should revert receiveTransfer call from a non-contract', async function () {
    await contract.receiveTransfer(accounts[0], value, token.address, dataCustom, { from: accounts[0] })
      .should.be.rejectedWith(EVMRevert);
  });
});
