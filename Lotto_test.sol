// SPDX-License-Identifier: GPL-3.0
    
pragma solidity >=0.6.2 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/Lotto.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    
    Lotto lotto;

    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeEach() public {
        lotto = new Lotto();
        Assert.equal(uint(1), uint(1), "1 should be equal to 1");
    }
    
    //ENTRY test cases
    
    ///case 1: when: fee too much -> then: return money, don't enter
    /// #sender: account-0
    /// #value: 600000000000000
    function entryFeeExceedsRequirement() public payable {
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
    
    ///case 3: when already entered -> then: return money, don't enter
    
    ///case 4: lottery already completed -> then: return money, don't enter
    
    ///case 5: Winner selection in progress -> then: return money, don't enter
    
    ///case 6: enter successfully
    /// #sender: account-0
    /// #value: 500000000000000
    function enterSuccessfully() public payable {
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(0), "expecting 0 entrants before entering");
        Assert.equal(lotto.getLotteryBalance(), uint256(0), "expecting 0 lottery balance before entering");

        
        lotto.enter{value:500000000000000}();
        
        Assert.equal(lotto.getLotteryBalance(), uint256(500000000000000), "expecting lottery balance equal to entrance fee after entering");
        Assert.equal(lotto.getQuantityOfEntrants(), uint256(1), "user should have successfully entered the lottery");
    }
    
    ///case 7: multiple entrants

    function checkSuccess() public {
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        Assert.ok(2 == 2, 'should be true');
        Assert.greaterThan(uint(2), uint(1), "2 should be greater than to 1");
        Assert.lesserThan(uint(2), uint(3), "2 should be lesser than to 3");
    }

    function checkSuccess2() public pure returns (bool) {
        // Use the return value (true or false) to test the contract
        return true;
    }
    
    function checkFailure() public {
        Assert.notEqual(uint(1), uint(1), "1 should not be equal to 1");
    }

    /// Custom Transaction Context: https://remix-ide.readthedocs.io/en/latest/unittesting.html#customization
    /// #sender: account-1
    /// #value: 100
    function checkSenderAndValue() public payable {
        // account index varies 0-9, value is in wei
        Assert.equal(msg.sender, TestsAccounts.getAccount(1), "Invalid sender");
        Assert.equal(msg.value, 100, "Invalid value");
    }
}
