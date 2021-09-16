pragma solidity 0.6.12;
import "./provableAPI.sol";

//TODO setup build system (truffle)
contract Lotto is usingProvable {
    address payable[] public entrants;
    mapping(address => uint) public balances;
    uint256 public entranceFee = 500000000000000; //50000; //wei
    uint256 public moneyDistributedDebug = 3;
    
    address payable public winner;
    bytes32 provableQueryId;
    constructor() public {}
    
    function enter() external payable {
        require(msg.value==entranceFee, "Invalid entry fee provided.");
        require(balances[msg.sender] == 0, "User has already entered. Only one entry allowed per address.");
        require(winnerHasNotBeenSet(), "Lottery has already completed. A winner was already selected.");
        require(provableQueryHasNotRun(), "Winner selection already in progress. No entries allowed now.");
        
        balances[msg.sender] = msg.value;
        entrants.push(msg.sender);
    }
    
    /*
    function enterDebug1() external payable {
        require(msg.sender == 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, "debug, incorrect sender");
    }*/
    
    function getLotteryBalance() public returns (uint256) {
       return address(this).balance;
    }
    
    function getQuantityOfEntrants() public view returns(uint count) {
        return entrants.length;
    }
    
    function selectWinner() public {
        if(winnerHasNotBeenSet() && provableQueryHasNotRun()){ //could this get stuck and prevent the money from being distributed? add a back-door for creator?
            provableQueryId = provable_query("WolframAlpha", constructProvableQuery()); //TODO switch to more secure source
            //__callback function is activated
        }
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
        if(myid != provableQueryId) revert();
        winner = entrants[parseInt(result)];
        distributeWinnings();
    }
    
    //TODO move to new file and restrict visibility
    function distributeWinnings() public returns (uint256) {
        //TODO check if winner has not been set yet
        winner.transfer(getLotteryBalance());
    }
}