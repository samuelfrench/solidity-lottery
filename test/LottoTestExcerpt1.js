const truffleAssert = require('truffle-assertions');
const { waitForEvent, validEntryValue } = require('./utils');

const Lotto = artifacts.require('Lotto');

contract('Lotto', async (accounts) => {
  let lotto;

  // helpers
  async function assertContractBalance(expectedBalance) {
    const actualBalance = await lotto.getLotteryBalance.call();
    assert.equal(actualBalance, expectedBalance);
  }

  async function assertEntrantCount(expectedEntrantCount) {
    const actualEntrantCount = await lotto.getQuantityOfEntrants.call();
    assert.equal(actualEntrantCount, expectedEntrantCount);
  }

  async function enterIntoLottoAndVerifyContractState(entrant = accounts[0], expectedEntrantCount = 1) {
    await lotto.enter({ value: validEntryValue, from: entrant });
    await assertEntrantCount(expectedEntrantCount);
    await assertContractBalance(validEntryValue * expectedEntrantCount);
  }

  beforeEach(async () => {
    lotto = await Lotto.new();

    await assertContractBalance(0);
    await assertEntrantCount(0);
  });

  it('allows lottery entry', async () => {
    await enterIntoLottoAndVerifyContractState();

    await assertContractBalance(validEntryValue);
    await assertEntrantCount(1);
  });
});
