// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "contracts/blackjack_interface.sol";

contract Blackjack is BlackjackInterface { 

    /*
    Insert comment here explaining code (Use msg.sender as the address of the player)
    */
    function startGame(uint betAmount) external {
        // initalize a hand for the dealer and the player (you can delete my comments for this function) 
        // include random number generator here that adds cards (you can delete my comments for this function) 
        emit handValueUpdated(); // log the value of the players new hand value
    }

    /*
    If action inputed == hit deal one card and add that to the value of the player hand 
    If playerHand < 21 call dealerAction()
    Else call blackJackOrBust
    If action == stand call dealerAction()
    */
    function playerAction(string memory action) external { // apparently the only want to compare memory strings to a regular string is through keccack256
        // if (action == "hit") { 
            // insert a new number into the array from a random number generator 1-10
            // blackjackOrBust();
        // }
        // else if (action == "stand") {
        //     // dealerAction();
        // } 
    }

    /*
    If dealerHandSum >= 17 call decideWinner()
    Else deal 1 card and add it to the value of dealerHand
    */
    function dealerAction() external {

    }

    /*
    Checks player's hand FIRST to see if handValue == 21 || handValue > 21   
    Checks dealer's hand SECOND to see if handValue == 21 || handValue > 21   
    If playerHandValue == 21 you win
    If dealerHandValue == 21 dealer win
    Call endgame()
    */
    function blackjackOrBust(uint handSum, string memory playerType) external {

    }

    /*
    Compare dealerhandsum and playerhandsum. Whichever is higher wins. Set the winner variable = winner.
    Edge case: both players hands are equal. In that case refund the bet amount. Set winner variable = tie.
    Call endGame()
    */
    function decideWinner() external {

    }

    /*
    Provide payout to winner. If the winner is player its 1.5*bet amount. 
    If its the dealer the contract get the bet amount from the player if that already hasnt been done in start game.
    Also if its a tie refund the bet amount to the player if they already paid at start of game.
    */
    function endGame() external {

    }

    function calculateHandValue() external view returns(uint) { // function to calculate hand value; might need to make a random number generator 1-10 
        // use a for loop and loop through the player hands
    }

}
