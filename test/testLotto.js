const truffleAssert = require('truffle-assertions');
const Lotto = artifacts.require("Lotto");

//TODO: Format file

contract("Lotto", async accounts => {

    let lotto;

    beforeEach(async () => {
        lotto = await Lotto.new();
        let balanceBefore = await lotto.getLotteryBalance.call();
        assert.equal(balanceBefore, 0);
        let entrantCountBefore = await lotto.getQuantityOfEntrants.call();
        assert.equal(entrantCountBefore, 0);
    });

  it("allows lottery entry", async () => {
    let enterResult = await lotto.enter({value: 500000000000000}); //TODO is this variable used

    let balanceAfter = await lotto.getLotteryBalance.call();
    assert.equal(balanceAfter, 500000000000000);
    let entrantCountAfter = await lotto.getQuantityOfEntrants.call();
    assert.equal(entrantCountAfter, 1);
  });



  it("prevents lottery entry if inadequate value provided in message", async() => {

    truffleAssert.reverts(lotto.enter({value: 400000000000000}), "Invalid entry fee provided.");

    let balanceAfter = await lotto.getLotteryBalance.call();
    assert.equal(balanceAfter, 0);
    let entrantCountAfter = await lotto.getQuantityOfEntrants.call();
    assert.equal(entrantCountAfter, 0);
  })

  //TODO: re-write tests from Lotto_test.sol
});