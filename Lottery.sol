pragma solidity >= 0.5.0 < 0.6.0;
import "github.com/provable-things/ethereum-api/provableAPI_0.5.sol";

contract Lotto is usingProvable {
    address[] public entrants;
    address public winner;
    bytes32 provableQueryId;
    
    function enter() public {
        entrants.push(msg.sender);
    }
    
    function selectWinner() public {
        if(winnerHasNotBeenSet() && provableQueryHasNotRun()){
            provableQueryId = provable_query("WolframAlpha", constructProvableQuery());
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
    
    //provable callback for selectWinner function
    function __callback(bytes32 myid, string memory result) public {
        if(myid != provableQueryId) revert();
        winner = entrants[parseInt(result)];
    }
}