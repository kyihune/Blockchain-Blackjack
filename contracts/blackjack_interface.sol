// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

interface BlackjackInterface {

    struct Hand {
        uint[] hand; // An array of cards we are going to store the hands in this struct
    }

    /*
    Insert comment here explaining code (Use msg.sender as the address of the player)
    */
    function startGame(uint betAmount) external;

    /*
    If action inputed == hit deal one card and add that to the value of the player hand 
    If playerHand < 21 call dealerAction()
    Else call BlackJackOrBust
    If action == stand call dealerAction()
    */
    function playerAction(string memory action) external;

    /*
    If dealerHandSum >= 17 call decideWinner()
    Else deal 1 card and add it to the value of dealerHand
    */
    function dealerAction() external;

    /*
    Checks player's hand FIRST to see if handValue == 21 || handValue > 21   
    Checks dealer's hand SECOND to see if handValue == 21 || handValue > 21   
    If playerHandValue == 21 you win
    If dealerHandValue == 21 Dealer win
    Call endgame()
    */
    function blackjackOrBust(uint handsum, string memory playerType) external;

    /*
    Compare dealerhandsum and playerhandsum. Whichever is higher wins. Set the winner variable = winner.
    Edge case: both players hands are equal. In that case refund the bet amount. Set winner variable = tie.
    Call endGame()
    */
    function decideWinner() external  ;

    /*
    Provide payout to winner. If the winner is player its 1.5*bet amount. 
    If its the dealer the contract get the bet amount from the player if that already hasnt been done in start game.
    Also if its a tie refund the bet amount to the player if they already paid at start of game.
    */
    function endGame() external;

    function calculateHandValue() external   view returns(uint); // function to calculate hand value

    event handValueUpdated(address indexed player, uint handValue); // log value of hand 

}
