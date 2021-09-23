pragma solidity 0.6.12;
import "./provableAPI.sol";

//TODO stop using provable (switch to chainlink)
contract Lotto is usingProvable {
    address payable[] public entrants;
    mapping(address => uint) public balances;
    uint256 public entranceFee = 5000000000000000; //wei
    uint256 public moneyDistributedDebug = 3;
    
    address payable public winner;

    bytes32 provableQueryId;
    event LogWinnerSelectionStarted(string message);
    event LogWinnerSelected(address winner);

    constructor () public{
        OAR = OracleAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
    }
    
    function enter() external payable {
        require(msg.value==entranceFee, "Invalid entry fee provided.");
        require(balances[msg.sender] == 0, "User has already entered. Only one entry allowed per address.");
        require(winnerHasNotBeenSet(), "Lottery has already completed. A winner was already selected.");
        require(provableQueryHasNotRun(), "Winner selection already in progress. No entries allowed now.");
        
        balances[msg.sender] = msg.value;
        entrants.push(msg.sender);
    }
    
    function getLotteryBalance() public returns (uint256) {
       return address(this).balance;
    }
    
    function getQuantityOfEntrants() public view returns(uint count) {
        return entrants.length;
    }

    //TODO restrict who can call this
    function selectWinner() public {
        require(getQuantityOfEntrants() > 0, "Requires at least one entrant to select a winner");
        require(winnerHasNotBeenSet(), "Winner has already been selected");
        require(provableQueryHasNotRun(), "Winner selection already in progress.");
        provableQueryId = provable_query("WolframAlpha", constructProvableQuery()); //TODO switch to more secure source
        emit LogWinnerSelectionStarted("Winner selection has started!" );
        //__callback function is activated
    }
    
    function winnerHasNotBeenSet() private view returns (bool){
        return winner == address(0);
    }
    
    function provableQueryHasNotRun() private view returns (bool){
        return provableQueryId == 0;
    }

    function constructProvableQuery() private view returns (string memory){
        return strConcat("random number between 0 and ", uint2str(entrants.length-1));
    }
    
    //provable callback for selectWinner function (this takes a while to be called)
    function __callback(bytes32 myid, string memory result) public override {
        //TODO validate sender
        if(myid != provableQueryId) revert();
        winner = entrants[parseInt(result)];
        distributeWinnings();
        emit LogWinnerSelected(winner);
    }
    
    //TODO move to new file and restrict visibility
    function distributeWinnings() public returns (uint256) {
        //TODO check if winner has not been set yet
        winner.transfer(getLotteryBalance());
    }
}
