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
        require(betAmount > 0, "Invalid Bet. Please bid over 0.");

        // Ensure the player has enough balance to start the game
        require(playerBalances[msg.sender] >= betAmount * 2, "Insufficient balance to start the game. You need 2 times the amount you bet to play.");

        // Deduct the bet amount from the player's balance
        playerBalances[msg.sender] -= betAmount;

        // Store bet amount and set gameStarted to True
        bet = betAmount;
        gameStarted = true;

        // initalize a hand for the dealer and the player; might need to add a delete for the hands just in case?
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
    function playerAction(bool hit) external { 
        
        if(hit) { // if you hit you push and the value gets automatically updated
            playerHands[msg.sender].hand.push(deal()); // not going to decide win
            emit handValueUpdated(msg.sender, calculateHandValue(playerHands[msg.sender])); // log value of the players new hand value again
        }

        if (calculateHandValue(playerHands[msg.sender].hand) >= 21) { // then you check either if you hit or if you stood if the value is >= 21 to go into the blackjackOrBust function
                blackjackOrBust(calculateHandValue(playerHands[msg.sender].hand), true);
        }

        //if the player stands or hits and the dealer's hand is greater than 17 decide the winner
        if(calculateHandValue(dealerHand) >= 17) { 
            decideWinner();
        }
        //if it isn't greater than 17 give the dealer a card and calculate the value of the hand again
        else {
            dealerHand.hand.push(deal());
            //If the dealer's hand's value is less than 21 call decideWinner() and if it is greater or equal call blackjackorBust()
            if(calculateHandValue(dealerHand) < 21) {
                decideWinner();
            }
            else {
                blackjackOrBust(calculateHandValue(dealerHand),false);
            }
        }
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
    Compare dealerhandsum and playerhandsum. Whichever is higher wins.
    Edge case: both players hands are equal. In that case refund the bet amount. 
    Call endGame()
    */

    function decideWinner() external {
        // Calculate the player's hand sum
        uint playerHandValue = 0;
        for (uint i = 0; i < playerHands[msg.sender].hand.length; i++) {
            playerHandValue += playerHands[msg.sender].hand[i];
        }

        // Calculate the dealer's hand sum
        uint dealerHandValue = 0;
        for (uint i = 0; i < dealerHand.hand.length; i++) {
            dealerHandValue += dealerHand.hand[i];
        }

        if (playerHandValue > 21) {
            win_lose_or_tie = 1; // Player busts, dealer wins
        } else if (dealerHandValue > 21) {
            win_lose_or_tie = 0; // Dealer busts, player wins
        } else if (playerHandValue == 21) {
            win_lose_or_tie = 0; // Player wins with blackjack
        } else if (dealerHandValue == 21) {
            win_lose_or_tie = 1; // Dealer wins with blackjack
        } else if (playerHandValue == dealerHandValue) {
            win_lose_or_tie = 2; // Tie
        } else if (playerHandValue > dealerHandValue) {
            win_lose_or_tie = 0; // Player wins
        } else {
            win_lose_or_tie = 1; // Dealer wins
        }

        endGame();
    }

    /*
    Provide payout to winner. If the winner is player its 1.5*bet amount. 
    If its the dealer the contract get the bet amount from the player if that already hasnt been done in start game.
    Also if its a tie refund the bet amount to the player if they already paid at start of game.
    */
    function endGame() external {

    }

    //Calculates the value of the hand of player or dealer
    function calculateHandValue(uint[] memory hand) internal  view returns(uint) { // function to calculate hand value; might need to make a random number generator 1-10 
        uint total = 0;
        for(uint i = 0; i < hand.length; i++) {
            total += hand[i];
        }
        return total;
    }
}


