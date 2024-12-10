const {expect} = require("chai");
const {ethers} = require("hardhat")

describe("Blackjack Contract", function(){
    it("betAmount 0 ", async function () {
        //initializes this variable as a deployed Blackjack contract
        const Blackjack = await ethers.deployContract("Blackjack");
        //gonna use these later
        //const [player] = await ethers.getSigners();
       // const playerBalance = await hardhatToken.balanceOf(player.address);
       // await blackjack.deployed();
        //.target gives the contract address
        console.log("blackjack deployed at:" + Blackjack.target);
        await expect(Blackjack.startGame(0)).to.be.revertedWith("Invalid Bet. Please bid over 0.");
    });

})
