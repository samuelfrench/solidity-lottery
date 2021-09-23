const truffleAssert = require('truffle-assertions');
const { waitForEvent, validEntryValue } = require('./utils');

const Lotto = artifacts.require('Lotto');

contract('Lotto', async (accounts) => {
  let lotto;

  // helpers
  async function enterIntoLottoAndVerifyContractState(entrant = accounts[0], expectedEntrantCount = 1) {
    await lotto.enter({ value: validEntryValue, from: entrant });
    await assertEntrantCount(expectedEntrantCount);
    await assertContractBalance(validEntryValue*expectedEntrantCount);
  }

  async function selectWinnerAndWaitForCompletion() {
    const selectWinnerResult = await lotto.selectWinner();
    await truffleAssert.eventEmitted(selectWinnerResult, 'LogWinnerSelectionStarted');
    await waitForEvent('LogWinnerSelected', lotto);
  }

  async function assertContractBalance(expectedBalance){
    const actualBalance = await lotto.getLotteryBalance.call(); // TODO break out into another helper function
    assert.equal(actualBalance, expectedBalance);
  }

  async function assertEntrantCount(expectedEntrantCount){
    const actualEntrantCount = await lotto.getQuantityOfEntrants.call();
    assert.equal(actualEntrantCount, expectedEntrantCount);
  }

  beforeEach(async () => {
    lotto = await Lotto.new();

    await assertContractBalance(0);
    await assertEntrantCount(0);
  });

  // BEGIN ENTRY RELATED TESTS
  it('allows lottery entry', async () => {
    await enterIntoLottoAndVerifyContractState();

    await assertContractBalance(validEntryValue)
    await assertEntrantCount(1);
  });

  it('allows lottery entry with multiple entrants', async () => {
    await enterIntoLottoAndVerifyContractState();
    await enterIntoLottoAndVerifyContractState(accounts[1], expectedEntrantCount = 2);

    await assertContractBalance(validEntryValue*2)
    await assertEntrantCount(2);
  });

  it('prevents lottery entry if insufficient entry fee provided', async () => {
    await truffleAssert.reverts(lotto.enter({ value: validEntryValue - 1 }), 'Invalid entry fee provided.');

    await assertContractBalance(0)
    await assertEntrantCount(0);
  });

  it("prevents lottery entry if entry fee provided is greater than what's required", async () => {
    await truffleAssert.reverts(lotto.enter({ value: validEntryValue + 1 }), 'Invalid entry fee provided.');

    await assertContractBalance(0);
    await assertEntrantCount(0);
  });

  it('prevents lottery entry if the address has already been entered into the lottery', async () => {
    await enterIntoLottoAndVerifyContractState();

    await truffleAssert.reverts(lotto.enter({ value: validEntryValue }), 'User has already entered. Only one entry allowed per address.');

    await assertContractBalance(validEntryValue);
    await assertEntrantCount(1);
  });

  it('prevents entry into the lottery if winner selection is in progress', async () => {
    await enterIntoLottoAndVerifyContractState();
    await lotto.selectWinner();

    await truffleAssert.reverts(lotto.enter({ value: validEntryValue, from: accounts[1] }),
      'Winner selection already in progress. No entries allowed now.');

    await assertContractBalance(validEntryValue);
    await assertEntrantCount(1);
  });

  it('prevents entry into the lottery once a winner has already been selected', async () => {
    await enterIntoLottoAndVerifyContractState();
    await selectWinnerAndWaitForCompletion();

    await truffleAssert.reverts(lotto.enter({ value: validEntryValue, from: accounts[1] }),
      'Lottery has already completed. A winner was already selected.');

    await assertContractBalance(0);
  });

  // Note: Truffle (or provable bridge) doesn't work well with a single contract having multiple test files TODO reproduce and file bug report
  // BEGIN WINNER SELECTION RELATED TESTS

  it('allows winner selection with a single entrant and distributes the funds', async () => {
    // given
    await enterIntoLottoAndVerifyContractState(accounts[1]);
    const winnerBalanceBefore = await web3.eth.getBalance(accounts[1]); // after entering but before winning

    // when
    await selectWinnerAndWaitForCompletion();

    // then
    await assertContractBalance(0);
    const winnerBalanceAfter = await web3.eth.getBalance(accounts[1]); //TODO break into helper function?
    // balance after winning should equal balance before winning + entry fee for 1 user
    assert.equal(parseInt(winnerBalanceAfter), parseInt(winnerBalanceBefore) + parseInt(validEntryValue),
      'Winner account balance incorrect after lottery completion.');
  });

  // TODO: Happy path - money distributed to winner 2 entrant

  // TODO: Nobody has entered yet, cannot select winner
  it('prevents kicking off winner selection if there are no entrants', async () => {
    await truffleAssert.reverts(lotto.selectWinner(), 'Requires at least one entrant to select a winner.');
  })

  // TODO: Winner selection already in progress, cannot select winner
  it('prevents kicking off winner selection if winner selection is already in progress', async () => {
    await enterIntoLottoAndVerifyContractState();
    await lotto.selectWinner();

    await truffleAssert.reverts(lotto.selectWinner(), 'Winner selection already in progress.');
  })

  // TODO: Winner already selected, cannot select winner

  // TODO: Callback function called from incorrect account, transaction reverted
});
