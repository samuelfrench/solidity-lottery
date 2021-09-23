const truffleAssert = require('truffle-assertions');
const { waitForEvent, validEntryValue } = require('./utils');

const Lotto = artifacts.require('Lotto');

contract('Lotto', async (accounts) => {
  let lotto;

  // helpers
  async function enterIntoLottoAndVerifyContractState(entrant, expectedEntrantCount = 1) {
    await lotto.enter({ value: validEntryValue, from: entrant });
    const entrantCount = await lotto.getQuantityOfEntrants.call();
    assert.equal(entrantCount, expectedEntrantCount);

    const contractBalance = await lotto.getLotteryBalance.call();
    assert.equal(contractBalance, validEntryValue * expectedEntrantCount);
  }

  beforeEach(async () => {
    lotto = await Lotto.new();

    const balanceBefore = await lotto.getLotteryBalance.call();
    assert.equal(balanceBefore, 0);
    const entrantCountBefore = await lotto.getQuantityOfEntrants.call();
    assert.equal(entrantCountBefore, 0);
  });

  // BEGIN ENTRY RELATED TESTS
  it('allows lottery entry', async () => {
    await enterIntoLottoAndVerifyContractState(accounts[0]);

    const balanceAfter = await lotto.getLotteryBalance.call();
    assert.equal(balanceAfter, validEntryValue);
    const entrantCountAfter = await lotto.getQuantityOfEntrants.call();
    assert.equal(entrantCountAfter, 1);
  });

  it('allows lottery entry with multiple entrants', async () => {
    await enterIntoLottoAndVerifyContractState(accounts[0]);
    await enterIntoLottoAndVerifyContractState(accounts[1], expectedEntrantCount = 2);

    const balanceAfter = await lotto.getLotteryBalance.call();
    assert.equal(balanceAfter, validEntryValue * 2);
    const entrantCountAfter = await lotto.getQuantityOfEntrants.call();
    assert.equal(entrantCountAfter, 2);
  });

  it('prevents lottery entry if insufficient entry fee provided', async () => {
    await truffleAssert.reverts(lotto.enter({ value: validEntryValue - 1 }), 'Invalid entry fee provided.');

    const balanceAfter = await lotto.getLotteryBalance.call();
    assert.equal(balanceAfter, 0);
    const entrantCountAfter = await lotto.getQuantityOfEntrants.call();
    assert.equal(entrantCountAfter, 0);
  });

  it("prevents lottery entry if entry fee provided is greater than what's required", async () => {
    await truffleAssert.reverts(lotto.enter({ value: validEntryValue + 1 }), 'Invalid entry fee provided.');

    const balanceAfter = await lotto.getLotteryBalance.call();
    assert.equal(balanceAfter, 0);
    const entrantCountAfter = await lotto.getQuantityOfEntrants.call();
    assert.equal(entrantCountAfter, 0);
  });

  it('prevents lottery entry if the address has already been entered into the lottery', async () => {
    const enterResult = await lotto.enter({ value: validEntryValue });

    await truffleAssert.reverts(lotto.enter({ value: validEntryValue }), 'User has already entered. Only one entry allowed per address.');
  });

  it('prevents entry into the lottery if winner selection is in progress', async () => {
    const enterResult = await lotto.enter({ value: validEntryValue });
    await lotto.selectWinner();

    await truffleAssert.reverts(lotto.enter({ value: validEntryValue, from: accounts[1] }),
      'Winner selection already in progress. No entries allowed now.');
  });

  it('prevents entry into the lottery once a winner has already been selected', async () => {
    await lotto.enter({ value: validEntryValue });
    const selectWinnerResult = await lotto.selectWinner();
    await truffleAssert.eventEmitted(selectWinnerResult, 'LogWinnerSelectionStarted');
    await waitForEvent('LogWinnerSelected', lotto);

    await truffleAssert.reverts(lotto.enter({ value: validEntryValue, from: accounts[1] }),
      'Lottery has already completed. A winner was already selected.');
  });

  // Note: Truffle (or provable bridge) doesn't work well with a single contract having multiple test files TODO reproduce and file bug report
  // BEGIN WINNER SELECTION RELATED TESTS

  it('allows winner selection with a single entrant and distributes the funds', async () => {
    // given
    await enterIntoLottoAndVerifyContractState(accounts[1]);
    const winnerBalanceBefore = await web3.eth.getBalance(accounts[1]); // after entering but before winning

    // when
    const selectWinnerResult = await lotto.selectWinner();
    await truffleAssert.eventEmitted(selectWinnerResult, 'LogWinnerSelectionStarted');
    await waitForEvent('LogWinnerSelected', lotto);

    // then - TODO cleanup into helper functions
    const completedContractBalance = await lotto.getLotteryBalance.call();
    const winnerBalanceAfter = await web3.eth.getBalance(accounts[1]);

    assert.equal(completedContractBalance, 0);
    // balance after winning should equal balance before winning + entry fee for 1 user
    assert.equal(parseInt(winnerBalanceAfter), parseInt(winnerBalanceBefore) + parseInt(validEntryValue),
      'Winner account balance incorrect after lottery completion.');
  });

  // TODO: Happy path - money distributed to winner 2 entrant

  // TODO: Winner selection already in progress, cannot select winner

  // TODO: Winner already selected, cannot select winner

  // TODO: Nobody has entered yet, cannot select winner

  // TODO: Callback function called from incorrect account, transaction reverted
});
