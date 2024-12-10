// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

interface BlackjackInterface {

    struct Hand {
        uint[] hand; // An array of cards we are going to store the hands in this structure
    }

    /*
    Check if requirements are met before playing
    Take money out of playerBalance and store it into a variable and oficially starting the game
    Add two cards into both the player's and dealer's hand with deal() function
    Log the values
    */
    function startGame(uint betAmount) external;

    /*
    If action inputed == hit deal one card and add that to the value of the player hand 
    If playerHand < 21 call dealerAction()
    Else call BlackJackOrBust
    If action == stand call dealerAction()
    
    DealerAction: Implemented in playerAction
    If dealerHandSum >= 17 call decideWinner()
    Else deal 1 card and add it to the value of dealerHand
    */
    function playerAction(bool hit) external;

    event handValueUpdated(address indexed player, uint handValue); // log value of hand 

}