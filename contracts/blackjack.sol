// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "contracts/blackjack_interface.sol";


contract Blackjack is BlackjackInterface { 
    uint256 someNumber = 7;//used in the random number generation process.
    bool gameStarted = false; //for the start game function
    bool isHit; //for player and dealer choice. false for stand, true for hit
    bool isPlayer; //this is to pass on to blackjackorbust. if its true the player is calling. if its false its the dealer
    uint bet = 0; //bet amount
    uint win_lose_or_tie;// 0 is win for the player, 1 is lose for the player, 2 is tie.


    //internal because we only want the contract to be able to call this
    function deal() internal  returns (uint){
        uint randomNumber = uint256(keccak256(abi.encodePacked(msg.sender, block.difficulty,  someNumber, address(this))));
        uint card = (randomNumber%10)+1;
        someNumber += 1;
        return card;
    }

    //Mapping to store player balances
    mapping(address => uint) public playerBalances;
    // Mapping to store each player's hand
    mapping(address => Hand) private playerHands;
    // Dealer's hand
    Hand private dealerHand;

    /*
    Check if requirements are met before playing
    Take money out of playerBalance and store it into a variable and oficially starting the game
    Add two cards into both the player's and dealer's hand with deal() function
    Log the values
    */
    function startGame(uint betAmount) external {
        // Ensure the player places a vaild bid
        require(betAmount == 0, "Invalid Bet. Please bid over 0.");

        // Ensure the player has enough balance to start the game
        require(playerBalances[msg.sender] >= betAmount * 2, "Insufficient balance to start the game. You need 2 times the amount you bet to play.");

        // Deduct the bet amount from the player's balance
        playerBalances[msg.sender] -= betAmount;

        // Store bet amount and set gameStarted to True
        bet = betAmount;
        gameStarted = true;

        // initalize a hand for the dealer and the player
        for(uint i = 0; i < 2; i++){
            playerHands[msg.sender].hand.push(deal());
            dealerHand.hand.push(deal());
        }

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
    Prematurely ends the game in 2 cases:
    1. the player or the dealer gets blackjack.
    2. the player or dealer busts.
    Only gets called during player or dealer action when the hand sum calculation is >=21 
    takes in the handSum(uint), and the type of player who the sum belongs to(player or dealer boolean)
    
    function blackjackOrBust(uint handSum, bool playerType) internal {
        if((handSum == 21 && playerType == true) || (handSum > 21 && playerType == false))
        {
            win_lose_or_tie = 0; //player gets blackjack or dealer busts
        }
        else if((handSum == 21 && playerType == false) || (handSum > 21 && playerType == true))
        {
            win_lose_or_tie = 1; //dealer gets blackjack or player busts
        }
        //i believe the correct function to call would be endGame but we'll have to make sure on that. for now its commented out.
        //endGame()
    }
    */

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
