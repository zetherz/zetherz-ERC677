const { advanceBlock } = require('openzeppelin-solidity/test/helpers/advanceToBlock');
const { EVMRevert } = require('openzeppelin-solidity/test/helpers/EVMRevert');

const BigNumber = web3.BigNumber;

const should = require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

const ERC677TokenMock = artifacts.require('ERC677TokenMock');
const LibMock = artifacts.require('LibMock');

function checkEventLogs (logs, eventName, args) {
  var argsNum = Object.keys(args).length;
  var event = logs.find(e => (e.event === eventName) && (Object.keys(e.args).length === argsNum));
  should.exist(event);
  for (var prop in args) {
    if (args[prop] === null) {
      continue;
    }
    if (args.hasOwnProperty(prop)) {
      if (event.args[prop] instanceof BigNumber) {
        event.args[prop].should.be.bignumber.equal(args[prop]);
      } else {
        event.args[prop].should.equal(args[prop]);
      }
    }
  }
}

contract('ERC677Token', function ([_, owner, wallet, thirdparty]) {
  const value = 42;
  const dataCustom = '1337';

  let token;

  before(async function () {
    // Advance to the next block to correctly read time in the solidity "now" function interpreted by ganache
    await advanceBlock();

    token = await ERC677TokenMock.new(owner, 1000, { from: owner });
  });

  describe('should not succeed to non-contract address', async function () {
    it('should fail approveAndCall', async function () {
      await token.approveAndCall(thirdparty, value, dataCustom, { from: owner }).should.be.rejectedWith(EVMRevert);
    });

    it('should fail transferAndCall', async function () {
      await token.transferAndCall(thirdparty, value, dataCustom, { from: owner }).should.be.rejectedWith(EVMRevert);
    });
  });

  describe('should succeed to ERC677 contract address w/ receive* functions', async function () {
    let contract;

    before(async function () {
      contract = await ERC677TokenMock.new(owner, 1000, { from: owner });
    });

    it('should approveAndCall', async function () {
      const { logs } = await token.approveAndCall(contract.address, value, dataCustom, { from: owner });
      checkEventLogs(logs, 'ReceiveApproval', { from: owner, value: value, tokenContract: token.address, data: null });
    });

    it('should transferAndCall', async function () {
      const { logs } = await token.transferAndCall(contract.address, value, dataCustom, { from: owner });
      checkEventLogs(logs, 'ReceiveTransfer', { from: owner, value: value, tokenContract: token.address, data: null });
    });
  });

  describe('should not succeed to contract address w/o receive* functions', async function () {
    let contract;

    before(async function () {
      contract = await LibMock.new();
    });

    it('should fail approveAndCall', async function () {
      await token.approveAndCall(contract.address, value, dataCustom, { from: owner })
        .should.be.rejectedWith(EVMRevert);
    });

    it('should fail transferAndCall', async function () {
      await token.transferAndCall(contract.address, value, dataCustom, { from: owner })
        .should.be.rejectedWith(EVMRevert);
    });
  });
});
