const Lotto = artifacts.require("Lotto");

//TODO: Format file

contract("Lotto", async accounts => {

    let lotto;

    beforeEach(async () => {
        lotto = await Lotto.deployed();
    });

  it("expecting 0 balance at contract creation", async () => {
    let balance = await lotto.getLotteryBalance.call()
    assert.equal(balance, 0);
  });

  it("allows lottery entry", async () => {
    let balanceBefore = await lotto.getLotteryBalance.call()
    assert.equal(balanceBefore, 0);
    let entrantCountBefore = await lotto.getQuantityOfEntrants.call()
    assert.equal(entrantCountBefore, 0);

    let enterResult = await lotto.enter({value: 500000000000000});

    let balanceAfter = await lotto.getLotteryBalance.call()
    assert.equal(balanceAfter, 500000000000000);
    let entrantCountAfter = await lotto.getQuantityOfEntrants.call()
    assert.equal(entrantCountAfter, 1);
  });

  //TODO: re-write tests from Lotto_test.sol
});