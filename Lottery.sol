pragma solidity 0.6.12;
import "github.com/provable-things/ethereum-api/provableAPI_0.6.sol";

//TODO this needs testing
contract Lotto is usingProvable {
    address[] public entrants;
    mapping(address => uint) public balances; //TODO is this needed
    uint256 public entranceFee = 5000;
    
    address public winner;
    bytes32 provableQueryId;
    
    function enter() external payable {
        if(balances[msg.sender] == 0 && msg.value==entranceFee){
            balances[msg.sender] = msg.value;
            entrants.push(msg.sender);
        } //else you have not paid the entry fee or have already entered
    }
    
    function getLotteryBalance() public returns (uint256) {
       return address(this).balance;
    }
    
    function selectWinner() public {
        if(winnerHasNotBeenSet() && provableQueryHasNotRun()){
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
    function distributeWinnings() public {
        if (!payable(winner).send(getLotteryBalance())) {
            //handle failed send TODO throw an error here
        }
    }
}
