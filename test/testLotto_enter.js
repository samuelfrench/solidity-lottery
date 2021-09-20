const truffleAssert = require('truffle-assertions');
const { waitForEvent, validEnterValue } = require('./utils')

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

  it('allows lottery entry', async () => {
    await lotto.enter({ value: validEnterValue});

    const balanceAfter = await lotto.getLotteryBalance.call();
    assert.equal(balanceAfter, validEnterValue);
    const entrantCountAfter = await lotto.getQuantityOfEntrants.call();
    assert.equal(entrantCountAfter, 1);
  });

  it('allows lottery entry with multiple entrants', async () => {
    await lotto.enter({ value: validEnterValue });
    await lotto.enter({ value: validEnterValue, from: accounts[1] });

    const balanceAfter = await lotto.getLotteryBalance.call();
    assert.equal(balanceAfter, validEnterValue*2);
    const entrantCountAfter = await lotto.getQuantityOfEntrants.call();
    assert.equal(entrantCountAfter, 2);
  });

  it('prevents lottery entry if insufficient entry fee provided', async () => {
    await truffleAssert.reverts(lotto.enter({ value: validEnterValue-1 }), 'Invalid entry fee provided.');

    const balanceAfter = await lotto.getLotteryBalance.call();
    assert.equal(balanceAfter, 0);
    const entrantCountAfter = await lotto.getQuantityOfEntrants.call();
    assert.equal(entrantCountAfter, 0);
  });

  it("prevents lottery entry if entry fee provided is greater than what's required", async () => {
    await truffleAssert.reverts(lotto.enter({ value: validEnterValue+1 }), 'Invalid entry fee provided.');

    const balanceAfter = await lotto.getLotteryBalance.call();
    assert.equal(balanceAfter, 0);
    const entrantCountAfter = await lotto.getQuantityOfEntrants.call();
    assert.equal(entrantCountAfter, 0);
  });

  it('prevents lottery entry if the address has already been entered into the lottery', async () => {
    const enterResult = await lotto.enter({  value: validEnterValue });

    await truffleAssert.reverts(lotto.enter({  value: validEnterValue }), 'User has already entered. Only one entry allowed per address.');
  });

  it('prevents entry into the lottery if winner selection is in progress', async () => {
    const enterResult = await lotto.enter({  value: validEnterValue });
    await lotto.selectWinner();

    await truffleAssert.reverts(lotto.enter({  value: validEnterValue, from: accounts[1] }),
      'Winner selection already in progress. No entries allowed now.');
  });

  it('prevents entry into the lottery once a winner has already been selected', async () => {
    await lotto.enter({ value: validEnterValue });
    const selectWinnerResult = await lotto.selectWinner();
    await truffleAssert.eventEmitted(selectWinnerResult, 'LogWinnerSelectionStarted');
    await waitForEvent('LogWinnerSelected', lotto);

    await truffleAssert.reverts(lotto.enter({ value: validEnterValue, from: accounts[1] }),
      'Lottery has already completed. A winner was already selected.');
  });
});
