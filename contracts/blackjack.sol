// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "contracts/blackjack_interface.sol";



contract Blackjack is BlackjackInterface {
    uint256 someNumber = 7;//used in the random number generation process. A code snippet online had it set to 0 but it can be anything.

    bool gameStarted = false; //for the start game function
    uint bet = 0; //bet amount

    uint win_lose_or_tie;// 0 is win for the player, 1 is lose for the player, 2 is tie.
    //these 2 values are used for testing. going to leave these and certain related lines of code in other functions uncommented.
    uint testPlayerHandValue;
    uint testDealerHandValue;
    //uncomment the variable below for testing.
    uint testcard = 0;



/*
   uncomment these functions if you want to run the tests.
   Don't really understand the recieve but apparently its needed. tests were working fine without it for betAmount.
*/

/*
    receive() external payable {}

    function viewGameStarted() external view returns (bool) {
        return gameStarted;
    }

    function viewDealtCard() external view returns (uint){
        return testcard;
    }

    function testDealCard() external{
        testcard = deal();
    }

    function viewPlayerHand() external view returns (uint){
        return testPlayerHandValue;
    }

    function viewDealerHand() external view returns (uint){
        return testDealerHandValue;
    }

   function testGameWinner(uint handValue, bool playerType) external  {
        blackjackOrBust(handValue, playerType);
    }

    function viewContractBalance() external view returns (uint) {
        return address(this).balance;
    }

    function testDecideWinner(uint playerHandValue, uint dealerHandValue) external {
        //copy and pasted from decide winner, removed some things that dont need to be tested.
        if(playerHandValue == dealerHandValue) {
            win_lose_or_tie = 2; // Tie
        }else if (playerHandValue > dealerHandValue) {
            win_lose_or_tie = 0; // Player wins
        }else {
            win_lose_or_tie = 1; // Dealer wins
        }
    }

    function viewGameWinner() external view returns(uint)
    {
        return win_lose_or_tie;
    }

    function viewPlayerBalance() external view returns (uint)
    {
        return playerBalances[msg.sender];
    }
*/

    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than 0.");
        playerBalances[msg.sender] += msg.value;
    }

    //internal because we only want the contract to be able to call this
    function deal() internal  returns (uint){
        //note that while testing the deal function I noticed after multiple tests the same 5 cards were being dealt, so added a few more parameters.
        //prevrandao and timestamp are bad cause the random number isnt truly random, miners and others can manipulate data of the timestamp or prevrandao
        //to get more favorable results while using the contract.
        uint randomNumber = uint256(keccak256(abi.encodePacked(msg.sender, block.prevrandao, msg.sender,block.timestamp,  someNumber, address(this))));
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
    Take money out of playerBalance and store it into a variable and officially starting the game
    Add two cards into both the player's and dealer's hand with deal() function
    Log the values
    */
    function startGame(uint betAmount) external {
        // Ensure the player places a vaild bet
        require(betAmount > 0, "Invalid Bet. Please bet over 0.");

        // Ensure the player has enough balance to start the game
        require(playerBalances[msg.sender] >= betAmount, "Insufficient balance to start the game.");

        // Deduct the bet amount from the player's balance
        playerBalances[msg.sender] -= betAmount;

        // Store bet amount and set gameStarted to True
        bet = uint(betAmount);
        gameStarted = true;

        // initalize a hand for the dealer and the player; might need to add a delete for the hands just in case?
        for(uint i = 0; i < 2; i++){
            playerHands[msg.sender].hand.push(deal());
            dealerHand.hand.push(deal());
        }
        testPlayerHandValue = calculateHandValue(playerHands[msg.sender].hand); //new line added for testing
        testDealerHandValue = calculateHandValue(dealerHand.hand); //new line added for testing
        uint playerHandValue = calculateHandValue(playerHands[msg.sender].hand);
        emit handValueUpdated(msg.sender,playerHandValue); // log the value of the players new hand value
    }

    /*


    If action inputed == hit deal one card and add that to the value of the player hand; log the value again 
    Then you check either if you hit or if you stood if the value is >= 21. If it is >= 21 you go straight into the blackjackOrBust function otherwise you let the dealer take his turn
    Dealer will only hit if card value is less than 17; if he has a value of 17 or greater he will use the hand to decide the win
    If he needs to hit then you push in a card and you check if it still less than 21 which he will then use the hand for
    If it is not < 21 which means > 21 or 21 then you must calculate blackjackorbust

    */
    function playerAction(bool hit) external {

        if(hit) { // if you hit you push and the value gets automatically updated
            playerHands[msg.sender].hand.push(deal()); 
            emit handValueUpdated(msg.sender, calculateHandValue(playerHands[msg.sender].hand)); // log value of the players new hand value again
        }


        //whether the player hits or stands this new line stores the value of their hand for a test we made.
        testPlayerHandValue = calculateHandValue(playerHands[msg.sender].hand); //new line added for testing

        if (calculateHandValue(playerHands[msg.sender].hand) >= 21) { // then you check either if you hit or if you stood if the value is >= 21 to go into the blackjackOrBust function

       
                blackjackOrBust(calculateHandValue(playerHands[msg.sender].hand), true);
        }

        //if the player stands or hits and the dealer's hand is greater than 17 decide the winner
        if(calculateHandValue(dealerHand.hand) >= 17) {
            testDealerHandValue = calculateHandValue(dealerHand.hand); //new line added for testing
            decideWinner();
        }
        //if it isn't greater than 17 give the dealer a card and calculate the value of the hand again
        else {
            dealerHand.hand.push(deal());
            testDealerHandValue = calculateHandValue(dealerHand.hand); //new line added for testing
            //If the dealer's hand's value is less than 21 call decideWinner() and if it is greater or equal call blackjackorBust()
            if(calculateHandValue(dealerHand.hand) < 21) {
                decideWinner();
            }
            else {
                blackjackOrBust(calculateHandValue(dealerHand.hand),false);
            }
        }
    }

    /*
    Prematurely ends the game in 2 cases:
    1. the player or the dealer gets blackjack.
    2. the player or dealer busts.
    Only gets called during player or dealer action when the hand sum calculation is >=21
    takes in the handSum(uint), and the type of player who the sum belongs to(player or dealer boolean)
    calls endGame at the end
    */
    function blackjackOrBust(uint handSum, bool playerType) internal {
        if((handSum == 21 && playerType == true) || (handSum > 21 && playerType == false))
        {
            win_lose_or_tie = 0; //player gets blackjack or dealer busts
        }
        else if((handSum == 21 && playerType == false) || (handSum > 21 && playerType == true))
        {
            win_lose_or_tie = 1; //dealer gets blackjack or player busts
        }

        /*I commented this out because playerAction goes through the whole loop. resulting in
           multiple calls to endGame()
        */
        //endGame()

    }


    /*
    Compare dealerhandsum and playerhandsum. Whichever is higher wins.
    Edge case: both players hands are equal. In that case refund the bet amount.
    Call endGame()
    */
    function decideWinner() internal {
        // Calculate the player's hand sum
        uint playerHandValue = calculateHandValue(playerHands[msg.sender].hand);

         // Calculate the dealer's hand sum
        uint dealerHandValue = calculateHandValue(dealerHand.hand);

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

    Provide payout to winner. If the winner is player its 2*bet amount. 

    If its the dealer the contract get the bet amount from the player if that already hasnt been done in start game.
    Also if its a tie refund the bet amount to the player 
    */
    function endGame() internal   {

        // 0 represents a win for the player

        if (win_lose_or_tie == 0 ){  

            (bool sent, ) = payable(msg.sender).call{value : 2*bet}(""); // Avoiding warnings
            require(sent, "Transfer failed.");// If sent is false, reports that the transfer has failed
        }
        else if (win_lose_or_tie == 1) {
            playerBalances[msg.sender] -= bet;
        }
        // 2 represents a tie for the player

        else if ( win_lose_or_tie == 2){
            playerBalances[msg.sender] +=bet;
        }    
        gameStarted = false;
    }

    //Calculates the value of the hand of player or dealer
    function calculateHandValue(uint[] memory hand)  internal pure    returns(uint) { // function to calculate hand value; might need to make a random number generator 1-10 

        uint total = 0;
        for(uint i = 0; i < hand.length; i++) {
            total += hand[i];
        }
        return total;
    }
}


