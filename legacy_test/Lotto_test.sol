// SPDX-License-Identifier: GPL-3.0

// INSTRUCTIONS: Run this in the "Solidity Unit Testing Plugin" within the remix IDE

pragma solidity 0.6.12;

// This import is automatically injected by Remix
import "remix_tests.sol";

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "./LottoMock.sol";
import "../contracts/Lotto.sol";

//TODO all this needs more testing
//TODO is lottomock needed? - verify at end
contract lottoEntranceTest is LottoMock {
    //ENTRY test cases

    ///case 1: when: fee too much -> then: return money, don't enter
    /// #sender: account-0
    /// #value: 6000000000000000
    function enterEntryFeeExceedsRequirement() public payable {
        Assert.equal(getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(getLotteryBalance(), uint256(6000000000000000), "expecting 0 lottery balance before entering"); //TODO this seems like an oddity with how the custom txn context is implemented with inheritance (could make a simplified case and report another issue)

        try this.enter{value:6000000000000000}() {
            Assert.ok(false, 'succeed unexpected');
        } catch Error(string memory reason) {
            Assert.equal(reason, "Invalid entry fee provided.", "It should fail due to invalid entry fee.");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'failed unexpected');
        }

        Assert.equal(getLotteryBalance(), uint256(6000000000000000), "expecting lottery balance equal to entrance fee after entering"); //TODO this seems like an oddity with how the custom txn context is implemented with inheritance
        Assert.equal(this.getQuantityOfEntrants(), uint256(0), "user should not have successfully entered the lottery");
    }

    ///case 6: enter successfully
    /// #sender: account-1
    /// #value: 5000000000000000
    function enterSuccessfullySingleEntrant() public payable {
        Assert.equal(getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(getLotteryBalance(), uint256(11000000000000000), "expecting 0 lottery balance before entering"); //TODO this seems like an oddity with how the custom txn context is implemented with inheritance

        this.enter{value:5000000000000000}();

        Assert.equal(getLotteryBalance(), uint256(11000000000000000), "expecting lottery balance equal to entrance fee after entering");  //TODO this seems like an oddity with how the custom txn context is implemented with inheritance
        Assert.equal(getQuantityOfEntrants(), uint256(1), "user should have successfully entered the lottery");
    }
}

contract lottoMultipleEntranceTest is Lotto {
    /// #sender: account-0
    /// #value: 5000000000000000
    function firstEntry() public payable {
        Assert.equal(getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(msg.sender, TestsAccounts.getAccount(0), "Invalid sender");

        enter();

        Assert.equal(getQuantityOfEntrants(), uint256(1), "user should have successfully entered the lottery");
    }

    /// #value: 5000000000000000
    /// #sender: account-1
    function secondEntry() public payable {
        Assert.equal(getQuantityOfEntrants(), uint256(1), "Expecting an existing entry.");
        Assert.equal(msg.sender, TestsAccounts.getAccount(1), "Invalid sender");

        //don't call function externally to use sender mocking
        enter();

        Assert.equal(getQuantityOfEntrants(), uint256(2), "second user should have successfully entered the lottery");
    }
}



/*
    ///case 2: when: fee too little -> then: return money, don't enter
    /// #sender: account-0
    /// #value: 1000
    function enterEntryFeeTooLittle() public payable {
        Assert.equal(this.getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(this.getLotteryBalance(), uint256(0), "expecting 0 lottery balance before entering");


        try this.enter{value:1000}() {
            Assert.ok(false, 'succeed unexpected');
        } catch Error(string memory reason) {
            Assert.equal(reason, "Invalid entry fee provided.", "It should fail due to invalid entry fee.");
        } catch (bytes memory ) {
            Assert.ok(false, 'failed unexpected');
        }

        Assert.equal(this.getLotteryBalance(), uint256(0), "expecting lottery balance equal to entrance fee after entering");
        Assert.equal(this.getQuantityOfEntrants(), uint256(0), "user should have successfully entered the lottery");
    }

    ///case 3: when already entered -> then: return money, don't enter
    /// #sender: account-0
    /// #value: 1000000000000000
    function enterAlreadyEntered() public payable {
        Assert.equal(this.getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(this.getLotteryBalance(), uint256(0), "expecting 0 lottery balance before entering");
        this.enter{value:5000000000000000}();
        Assert.equal(this.getLotteryBalance(), uint256(5000000000000000), "expecting lottery balance equal to entrance fee after entering");
        Assert.equal(this.getQuantityOfEntrants(), uint256(1), "user should have successfully entered the lottery");


        try this.enter{value:5000000000000000}() {
            Assert.ok(false, 'succeed unexpected');
        } catch Error(string memory reason) {
            Assert.equal(reason, "User has already entered. Only one entry allowed per address.", "Expected failure, user has already entered.");
        } catch (bytes memory ) {
            Assert.ok(false, 'failed unexpected');
        }

        Assert.equal(this.getLotteryBalance(), uint256(5000000000000000), "Lottery balance should be unchanged after failed entry");
        Assert.equal(this.getQuantityOfEntrants(), uint256(1), "User has already entered, only expecting 1 entrant.");
    }

    ///case 4: lottery already completed -> then: return money, don't enter
    function enterWinnerAlreadySelected() public payable {
        Assert.equal(this.getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(this.getLotteryBalance(), uint256(0), "expecting 0 lottery balance before entering");
        this.setWinner();

        try this.enter{value:5000000000000000}() {
            Assert.ok(false, 'succeed unexpected');
        } catch Error(string memory reason) {
            Assert.equal(reason, "Lottery has already completed. A winner was already selected.", "Lottery already completed. User cannot enter.");
        } catch (bytes memory ) {
            Assert.ok(false, 'failed unexpected');
        }

        Assert.equal(this.getLotteryBalance(), uint256(0), "expecting lottery balance equal to entrance fee after entering");
        Assert.equal(this.getQuantityOfEntrants(), uint256(0), "user should have successfully entered the lottery");
    }

    ///case 5: Winner selection in progress -> then: return money, don't enter
    function enterWinnerSelectionInProgress() public payable {
        Assert.equal(this.getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(this.getLotteryBalance(), uint256(0), "expecting 0 lottery balance before entering");
        this.setProvableQueryId();

        try this.enter{value:5000000000000000}() {
            Assert.ok(false, 'succeed unexpected');
        } catch Error(string memory reason) {
            Assert.equal(reason, "Winner selection already in progress. No entries allowed now.", "Cannot enter lottery when winner selection is in progress.");
        } catch (bytes memory) {
            Assert.ok(false, 'failed unexpected');
        }

        Assert.equal(this.getLotteryBalance(), uint256(0), "expecting lottery balance equal to entrance fee after entering");
        Assert.equal(this.getQuantityOfEntrants(), uint256(0), "user should have successfully entered the lottery");
    }
}
*/

