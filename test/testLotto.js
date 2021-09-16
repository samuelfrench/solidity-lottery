const Lotto = artifacts.require("Lotto");

contract("Lotto", async accounts => {
  it("expecting 0 balance at contract creation", async () => {
    let instance = await Lotto.deployed(); //TODO move to beforeEach
    let balance = await instance.getLotteryBalance.call()
    assert.equal(balance, 0);
  });

  it("allows lottery entry", async () => {
    let instance = await Lotto.deployed(); //TODO move to beforeEach
    let balanceBefore = await instance.getLotteryBalance.call()
    assert.equal(balanceBefore, 0);
    let entrantCountBefore = await instance.getQuantityOfEntrants.call()
    assert.equal(entrantCountBefore, 0);

    let enterResult = await instance.enter({value: 500000000000000});

    let balanceAfter = await instance.getLotteryBalance.call()
    assert.equal(balanceAfter, 500000000000000);
    let entrantCountAfter = await instance.getQuantityOfEntrants.call()
    assert.equal(entrantCountAfter, 1);
  });
});