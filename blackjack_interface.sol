pragma solidity >=0.4.2 <0.9.0;


/**
 * @title Declarations for Blackjack
 *
 * This interface could be missing some functions and possibly have some extra functions as well
 */
interface BlackjackInterface{

    // Card structure
    struct Card {
        uint suit; // Suit of a given card
        uint value; // Representing 1-13 from Ace to King
    }

    // Player structure
    struct Player{
        address playerAddress; // To identify player
        Card[] hand; // An array of cards
        uint bet; // Wager for the hand
    }

    // Function headers
    function startGame(address player) external; // Allows a player to start a game
    function declareBet(uint bet_value) external; // Allows the player to make a bet
    function dealCard(address player) external; // Deals a single card to specified address
    function hit() external; // Lets the player draw one more card
    function stand() external; // Stops asking the player if they want to draw cards
    function getPlayerHand(address player) external view returns (Card[] memory); // Function to return 
    function getDealerHand() external view returns (Card[] memory); // 
    function endHand() external view returns (address winner); // Finishes the hand and returns the winner

    // Event headers
    event gameStarted(address player); // To see when a game has started
    event betPlaced(address player, uint bet_amount); // To read placed bets
    event handDealt(address player, Card card); // To see where the last card was dealt and what it was
    event dealerBusted(); // Showing that the dealer has lost the hand
    event playerBusted(address player, uint hand_sum); // To see that a player busted
    event playerHit(address player); // Shows that the player has hit
    event playerStood(address player); // Shows that the player has stood
    event gameEnded(); // Showing the game has ended


}