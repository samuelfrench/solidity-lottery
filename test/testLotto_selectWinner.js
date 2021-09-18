const truffleAssert = require('truffle-assertions');
const { waitForEvent } = require('./utils')

const Lotto = artifacts.require('Lotto');


contract('Lotto', async (accounts) => {
  let lotto;

  beforeEach(async () => {
    lotto = await Lotto.new();

    const balanceBefore = await lotto.getLotteryBalance.call();
    assert.equal(balanceBefore, 0);
    const entrantCountBefore = await lotto.getQuantityOfEntrants.call();
    assert.equal(entrantCountBefore, 0);
  });

  //TODO: Happy path - money distributed to winner

  //TODO: Winner selection already in progress

  //TODO: Winner already selected

  //TODO: Nobody has entered yet

  //TODO: Callback function called from incorrect account

/*
  it('', async () => {
  });
  */
});
