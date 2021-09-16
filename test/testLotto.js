const Lotto = artifacts.require("Lotto");

contract("Lotto", async accounts => {
  it("expecting 0 balance at contract creation", async () => {
    let instance = await Lotto.deployed();
    let balance = await instance.getLotteryBalance.call()
    assert.equal(balance, 0);
  });
});