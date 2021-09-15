// SPDX-License-Identifier: GPL-3.0
    
pragma solidity >=0.6.2 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "./LottoMock.sol";

contract testSuite {
    
    //We need to use this "mock" object in order to modify internal states of the contract
    LottoMock lotto;

    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeEach() public {
        lotto = new LottoMock();
        Assert.equal(uint(1), uint(1), "1 should be equal to 1");
    }
    
    //ENTRY test cases
    
    ///case 1: when: fee too much -> then: return money, don't enter
    /// #sender: account-0
    /// #value: 600000000000000
    function enterEntryFeeExceedsRequirement() public payable {
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(lotto.getLotteryBalance(), uint256(0), "expecting 0 lottery balance before entering");

        
        try lotto.enter{value:600000000000000}() {
            Assert.ok(false, 'succeed unexpected');
        } catch Error(string memory reason) {
            Assert.equal(reason, "Invalid entry fee provided.", "It should fail due to invalid entry fee.");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'failed unexpected');
        }
        
        Assert.equal(lotto.getLotteryBalance(), uint256(0), "expecting lottery balance equal to entrance fee after entering");
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(0), "user should have successfully entered the lottery");
    }
    
    
    ///case 2: when: fee too little -> then: return money, don't enter
    /// #sender: account-0
    /// #value: 1000
    function enterEntryFeeTooLittle() public payable {
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(lotto.getLotteryBalance(), uint256(0), "expecting 0 lottery balance before entering");

        
        try lotto.enter{value:1000}() {
            Assert.ok(false, 'succeed unexpected');
        } catch Error(string memory reason) {
            Assert.equal(reason, "Invalid entry fee provided.", "It should fail due to invalid entry fee.");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'failed unexpected');
        }
        
        Assert.equal(lotto.getLotteryBalance(), uint256(0), "expecting lottery balance equal to entrance fee after entering");
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(0), "user should have successfully entered the lottery");
    }
    
    ///case 3: when already entered -> then: return money, don't enter
    /// #sender: account-0
    /// #value: 1000000000000000
    function enterAlreadyEntered() public payable {
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(lotto.getLotteryBalance(), uint256(0), "expecting 0 lottery balance before entering");
        lotto.enter{value:500000000000000}();
        Assert.equal(lotto.getLotteryBalance(), uint256(500000000000000), "expecting lottery balance equal to entrance fee after entering");
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(1), "user should have successfully entered the lottery");
        
                
        try lotto.enter{value:500000000000000}() {
            Assert.ok(false, 'succeed unexpected');
        } catch Error(string memory reason) {
            Assert.equal(reason, "User has already entered. Only one entry allowed per address.", "Expected failure, user has already entered.");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'failed unexpected');
        }
        
        Assert.equal(lotto.getLotteryBalance(), uint256(500000000000000), "Lottery balance should be unchanged after failed entry");
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(1), "User has already entered, only expecting 1 entrant.");
    }
    
    ///case 4: lottery already completed -> then: return money, don't enter
    function enterWinnerAlreadySelected() public payable {
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(lotto.getLotteryBalance(), uint256(0), "expecting 0 lottery balance before entering");
        lotto.setWinner();

        try lotto.enter{value:500000000000000}() {
            Assert.ok(false, 'succeed unexpected');
        } catch Error(string memory reason) {
            Assert.equal(reason, "Lottery has already completed. A winner was already selected.", "Lottery already completed. User cannot enter.");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'failed unexpected');
        }
        
        Assert.equal(lotto.getLotteryBalance(), uint256(0), "expecting lottery balance equal to entrance fee after entering");
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(0), "user should have successfully entered the lottery");
    }
    
    ///case 5: Winner selection in progress -> then: return money, don't enter
    function enterWinnerSelectionInProgress() public payable {
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(lotto.getLotteryBalance(), uint256(0), "expecting 0 lottery balance before entering");
        lotto.setProvableQueryId();

        try lotto.enter{value:500000000000000}() {
            Assert.ok(false, 'succeed unexpected');
        } catch Error(string memory reason) {
            Assert.equal(reason, "Winner selection already in progress. No entries allowed now.", "Cannot enter lottery when winner selection is in progress.");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'failed unexpected');
        }
        
        Assert.equal(lotto.getLotteryBalance(), uint256(0), "expecting lottery balance equal to entrance fee after entering");
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(0), "user should have successfully entered the lottery");
    }
    
    ///case 6: enter successfully
    function enterSuccessfullySingleEntrant() public payable {
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(lotto.getLotteryBalance(), uint256(0), "expecting 0 lottery balance before entering");

        
        lotto.enter{value:500000000000000}();
        
        Assert.equal(lotto.getLotteryBalance(), uint256(500000000000000), "expecting lottery balance equal to entrance fee after entering");
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(1), "user should have successfully entered the lottery");
    }
    
    ///case 7: multiple entrants
}
