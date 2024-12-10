const {expect} = require("chai");
const {ethers} = require("hardhat")

describe("Blackjack Contract", function(){
    it("all betAmount tests", async function () {
        //initializes this variable as a deployed Blackjack contract
        const Blackjack = await ethers.deployContract("Blackjack");
        const provider = ethers.provider;
        //gonna use these later
        const accounts = await ethers.getSigners();
        const player = accounts[0]
        const playerbalance = await provider.getBalance(player.address);
        //.target gives the contract address
        console.log("blackjack deployed at:" + Blackjack.target);

        console.log("Test 1.1: invalid starting bet amount. startGame(0) ");
        await expect(Blackjack.startGame(0)).to.be.revertedWith("Invalid Bet. Please bid over 0.");
        console.log("Test 1.2: player has insufficient funds when calling startGame(betAmount). player balance: "+ playerbalance);
        await expect(Blackjack.startGame(playerbalance)).to.be.revertedWith("Insufficient balance to start the game. You need 2 times the amount you bet to play.");




    });


})
