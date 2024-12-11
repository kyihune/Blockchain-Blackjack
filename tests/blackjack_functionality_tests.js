const {expect} = require("chai");
const {ethers} = require("hardhat");
//this is a very messy and redundant testing suite but it works.
describe("Blackjack Contract", function() {
    it("all betAmount tests", async function () {
        // Deploy the Blackjack contract and initial setup
        const Blackjack = await ethers.deployContract("Blackjack");
        const provider = ethers.provider;
        //gets a list of signer accounts. made possible by running an instance of npx hardhat node in terminal
        const accounts = await ethers.getSigners();
        //we only need 1 account for the player
        const player = accounts[0];
        // Setting the player's balance to 1 ETH
        await network.provider.send("hardhat_setBalance", [
            player.address,
            "0x100000000000000000",
        ]);
        //Sending 1 ETH to the Blackjack contract
        await player.sendTransaction({
            to: Blackjack.target,
            value: ethers.parseEther("1"),
        });
        //Depositing 1 Eth into the contract to be used for the blackjack game
        await Blackjack.connect(player).deposit({ value: ethers.parseEther("1") });
        const validBetAmount = ethers.parseEther("0.5");
        //Blackjack.target is the address of the contract
        console.log("blackjack deployed at:" + Blackjack.target);
        console.log("Test 1.1: invalid starting bet amount. startGame(0)");
        await expect(Blackjack.connect(player).startGame(0)).to.be.revertedWith("Invalid Bet. Please bid over 0.");
        let gameStarted = await Blackjack.viewGameStarted();
        console.log("Game started:", gameStarted);
        console.log("Test 1.2: player has sufficient funds when calling startGame(betAmount).");
        await expect(Blackjack.connect(player).startGame(validBetAmount)).to.not.be.reverted;
        gameStarted = await Blackjack.viewGameStarted();
        console.log("Game started:", gameStarted);
        expect(gameStarted).to.equal(true);
    });
    it("all blackjack or bust tests", async function () {
        const Blackjack = await ethers.deployContract("Blackjack");
        const provider = ethers.provider;
        const player = true;
        const dealer = false;
        const winningHand = 21;
        const losingHand = 22;
        console.log("Test 2.1: dealer gets blackjack: Expecting 1");
        await Blackjack.testGameWinner(winningHand, dealer);
        let winStatus = await Blackjack.viewGameWinner();
        expect(winStatus).to.equal(1);
        console.log("The dealer got blackjack: ", winStatus)
        console.log("Test 2.2: player gets blackjack: Expecting 0")
        await Blackjack.testGameWinner(winningHand, player);
        winStatus = await Blackjack.viewGameWinner();
        expect(winStatus).to.equal(0);
        console.log("The player got blackjack: ", winStatus);
        console.log("Test 2.3: player busts. Expecting 1")
        await Blackjack.testGameWinner(losingHand, player);
        winStatus = await Blackjack.viewGameWinner();
        expect(winStatus).to.equal(1);
        console.log("The player busts: ", winStatus);
        console.log("Test 2.4: dealer busts. Expecting 0")
        await Blackjack.testGameWinner(losingHand, dealer);
        winStatus = await Blackjack.viewGameWinner();
        expect(winStatus).to.equal(0);
        console.log("The dealer busts: ", winStatus);
    });
    it("all decideWinner tests", async function () {
        const Blackjack = await ethers.deployContract("Blackjack");
        const provider = ethers.provider;
        console.log("Test Player and Dealer have equal Hand Values: Expecting 2 indicating a tie");
        await Blackjack.testDecideWinner(20, 20);
        let winStatus = await Blackjack.viewGameWinner();
        expect(winStatus).to.equal(2);
        console.log("The result was a tie: ", winStatus);
        console.log("Test Player's hand value is greater than the dealer's hand value: Expecting 0");
        await Blackjack.testDecideWinner(20, 18);
        winStatus = await Blackjack.viewGameWinner();
        expect(winStatus).to.equal(0);
        console.log("The player won the game: ", winStatus);
        console.log("Test Dealer's Hand Value is greater than Player's hand value: Expecting 1");
        await Blackjack.testDecideWinner(16, 19);
        winStatus = await Blackjack.viewGameWinner();
        expect(winStatus).to.equal(1);
        console.log("The dealer won the game: ", winStatus);
    });
    it("testing deal function", async function (){
        const Blackjack = await ethers.deployContract("Blackjack");
        const provider = ethers.provider;
        console.log("The following tests are to see if deal, accurately deals cards randomly.");
        console.log("Some cards being duplicate are fine, but if the number is the same 5 times, they're may be something wrong with our code");
        console.log("whatever the case is, the cards dealt should not equal 0 or exceed 10");
        await Blackjack.testDealCard();
        let dealtCard = await Blackjack.viewDealtCard();
        expect(dealtCard).to.not.equal(0);
        //apparently according to chai documentation its not reccommended to use the to be at most so i will just do the expect to equal 0 test and log all the card values and compare manually.
        console.log("Card 1: ", dealtCard);
        await Blackjack.testDealCard();
        dealtCard = await Blackjack.viewDealtCard();
        expect(dealtCard).to.not.equal(0);
        console.log("Card 2: ", dealtCard);
        await Blackjack.testDealCard();
        dealtCard = await Blackjack.viewDealtCard();
        expect(dealtCard).to.not.equal(0);
        console.log("Card 3: ", dealtCard);
        await Blackjack.testDealCard();
        dealtCard = await Blackjack.viewDealtCard();
        expect(dealtCard).to.not.equal(0);
        console.log("Card 4: ", dealtCard);
        await Blackjack.testDealCard();
        dealtCard = await Blackjack.viewDealtCard();
        expect(dealtCard).to.not.equal(0);
        console.log("Card 5: ", dealtCard);
        //on the first test all 5 cards were different. test successful
    });
    it("testing playerAction hit", async function(){
        //the player action tests will also serve as a way to test calculateHandValue as we will be comparing before and afters. Unfortunately the dealers actions cannot be tested properly
        //however we can still compare dealers hand before and after to see if it made the correct decision to hit or stand as the code intended
        //we know decide winner and BlackjackorBust works so will not be testing that again.
        const Blackjack = await ethers.deployContract("Blackjack");
        const provider = ethers.provider;
        const accounts = await ethers.getSigners();
        const player = accounts[0];
        await Blackjack.connect(player).deposit({ value: ethers.parseEther("1") });
        const validBetAmount = ethers.parseEther("0.5");
        await Blackjack.connect(player).startGame(validBetAmount);
        console.log("player and dealer hands at the start of the game")
        let initialPlayerHand = await Blackjack.viewPlayerHand();
        console.log("Initial player hand: ", initialPlayerHand);
        let initialDealerHand = await Blackjack.viewDealerHand();
        console.log("Initial Dealer Hand: ", initialDealerHand);
        // Player chooses to hit
        await Blackjack.connect(player).playerAction(true);
        console.log("player and dealer hands after player chooses to hit")
        // After hitting, the player's hand value should have increased
        let newPlayerHand = await Blackjack.viewPlayerHand();
        console.log("New hand value after player hit: ", newPlayerHand);
        let newDealerHand = await Blackjack.viewDealerHand();
        console.log("New dealer hand based on dealer action: ", newDealerHand);
        /* in the first test on this player hand went from 18 to 28 which means they hit and got a 10. the dealer had 16 and went to 26. this means the dealer hit while under the value of 17 as intended
        one thing I noticed is that player action goes through the whole loop. I believe the intention was if a hand was >=21 it would call BlackjackorBust and end the game. something similar to a break in that if
        statement might solve this.*/
    });
    it("testing playerAction Stand", async function(){
        const Blackjack = await ethers.deployContract("Blackjack");
        const provider = ethers.provider;
        const accounts = await ethers.getSigners();
        const player = accounts[0];
        await Blackjack.connect(player).deposit({ value: ethers.parseEther("1") });
        const validBetAmount = ethers.parseEther("0.5");
        await Blackjack.connect(player).startGame(validBetAmount);
        console.log("player and dealer hands at the start of the game")
        let initialPlayerHand = await Blackjack.viewPlayerHand();
        console.log("Initial player hand: ", initialPlayerHand);
        let initialDealerHand = await Blackjack.viewDealerHand();
        console.log("Initial Dealer Hand: ", initialDealerHand);
        // Player chooses to stand
        await Blackjack.connect(player).playerAction(false);
        console.log("player and dealer hands after player chooses to stand")
        // After standing, the player's hand value should NOT have increased. it should be the same. line 161 checks that.
        let newPlayerHand = await Blackjack.viewPlayerHand();
        console.log("New hand value after player hit: ", newPlayerHand);
        expect(initialPlayerHand).to.equal(newPlayerHand);
        let newDealerHand = await Blackjack.viewDealerHand();
        console.log("New dealer hand based on dealer action: ", newDealerHand);
    });
    it("testing EndGame", async function(){
        /*during a round as long as a player makes an action hit or stand, the internal function EndGame will eventually be called. So to see if it works we will simulate a game and log the balances of the player and the contract when the game starts and the game ends. That way we can compare and see if the code works as intended.
        due to the unpredictability of the game we may have to run this test multiple times until we see all possible outcomees of the player and contract balances.
        in this test we will only simulate the player hitting which may not be realistic as a test.*/
        const Blackjack = await ethers.deployContract("Blackjack");
        const provider = ethers.provider;
        const accounts = await ethers.getSigners();
        const player = accounts[0];
        await Blackjack.connect(player).deposit({ value: ethers.parseEther("1") });
        const validBetAmount = ethers.parseEther("0.5");
        await Blackjack.connect(player).startGame(validBetAmount);
        console.log("player and dealer hands at the start of the game")
        let initialPlayerHand = await Blackjack.viewPlayerHand();
        console.log("Initial player hand: ", initialPlayerHand);
        let initialDealerHand = await Blackjack.viewDealerHand();
        console.log("Initial Dealer Hand: ", initialDealerHand);
        console.log("player and dealer balance at the start of the game");
        let playerStart = await Blackjack.connect(player).viewPlayerBalance();
        console.log("player: ", playerStart)
        let dealerStart = await Blackjack.viewContractBalance();
        console.log("dealer: ", dealerStart );
        await Blackjack.connect(player).playerAction(true);
        console.log("player and dealer hands after player chooses to hit")
        let newPlayerHand = await Blackjack.viewPlayerHand();
        console.log("New hand value after player hit: ", newPlayerHand);
        let newDealerHand = await Blackjack.viewDealerHand();
        console.log("New dealer hand based on dealer action: ", newDealerHand);
        console.log("player and dealer balance at the end of the game");
        console.log("player and dealer balance at the start of the game");
        let playerEnd = await Blackjack.connect(player).viewPlayerBalance();
        console.log("player: ", playerEnd);
        let dealerEnd = await Blackjack.viewContractBalance();
        console.log("dealer: ", dealerEnd );
        //noticed that endGame does not properly deduct from player's balance and add that to the contracts funds when the player loses
        //also its really hard to get a tie, I ran the test for like at least 5 times and didnt get a tie situation so dont know what happens with EndGame during a tie
    });
});
