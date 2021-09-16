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



  it("prevents lottery entry if insufficient entry fee provided", async() => {
    await truffleAssert.reverts(lotto.enter({value: 400000000000000}), "Invalid entry fee provided.");

    let balanceAfter = await lotto.getLotteryBalance.call();
    assert.equal(balanceAfter, 0);
    let entrantCountAfter = await lotto.getQuantityOfEntrants.call();
    assert.equal(entrantCountAfter, 0);
  });

    it("prevents lottery entry if entry fee provided is greater than what's required", async() => {
      await truffleAssert.reverts(lotto.enter({value: 600000000000000}), "Invalid entry fee provided.");

      let balanceAfter = await lotto.getLotteryBalance.call();
      assert.equal(balanceAfter, 0);
      let entrantCountAfter = await lotto.getQuantityOfEntrants.call();
      assert.equal(entrantCountAfter, 0);
    });

    it("prevents lottery entry if the address has already been entered into the lottery", async() => {
        let enterResult = await lotto.enter({value: 500000000000000});

        await truffleAssert.reverts(lotto.enter({value: 500000000000000}), "User has already entered. Only one entry allowed per address.");
    });

    it("prevents entry into the lottery if winner selection is in progress", async() => {
        let enterResult = await lotto.enter({value: 500000000000000});
        await lotto.selectWinner();

        await truffleAssert.reverts(lotto.enter({value: 500000000000000, from: accounts[1]}),
            "Winner selection already in progress. No entries allowed now.");
    });

    //TODO clean this up
    it("prevents entry into the lottery once a winner has already been selected", async() => {
        let enterResult = await lotto.enter({value: 500000000000000});

        let result = await lotto.selectWinner();

        await truffleAssert.eventEmitted(result, 'LogWinnerSelectionStarted');

        let events = await lotto.getPastEvents( 'LogWinnerSelected', { fromBlock: 0, toBlock: 'latest' } )

        let secondCounter = 0;
        const sleep = ms => new Promise(res => setTimeout(res, ms));
        while(events.length < 1){
            console.log("polling for winner selected event");
            await sleep(1000);
            secondCounter++;
            events = await lotto.getPastEvents( 'LogWinnerSelected', { fromBlock: 0, toBlock: 'latest' } )
            if(secondCounter > 100){
                assert(false);
            }
        }

        await truffleAssert.reverts(lotto.enter({value: 500000000000000, from: accounts[1]}),
                    "Lottery has already completed. A winner was already selected.");
    });

  //TODO: re-write tests from Lotto_test.sol
  const getFirstEvent = (_event) => {
    return new Promise((resolve, reject) => {
      _event.once('data', resolve).once('error', reject)
    });
  }
});