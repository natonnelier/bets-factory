// We import Chai to use its asserting functions here.
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { tomorrowUnix } = require('./helpers.ts');


describe("Bettable", function () {

    let Bettable;
    let contract;
    let owner;
    let user1;
    let user2;

    before(async function () {
        Bettable = await ethers.getContractFactory("Bettable");
        [owner, user1, user2] = await ethers.getSigners();

        contract = await Bettable.deploy();
    });

    // Test owner and deployment.
    describe("Deployment", function () {

        it("Should set the right owner", async function () {
            expect(await contract.owner()).to.equal(owner.address);
        })
    });

    // Connect to Oracle and get confirmation
    describe("Game Bets", function() {
        // set Games and bets
        let game1 = ethers.utils.formatBytes32String("game1");
        let game2 = ethers.utils.formatBytes32String("game2");

        before(async function() {
            await contract.placeBet(game1, 1, { value: 55 });
            await contract.placeBet(game2, 0, { value: 22 });
        })
        describe("place and retrieve bets", function() {

            it("getGames function retrieves an array with all Games", async function() {
                var _bets = await contract.getAllUserBets();
                expect(_bets.length).to.equal(2);
            })

            it("getBettableGames function retrieves an array with Games in Pending status", async function() {
                var _games = await contract.getAllGameBets(game1);
                expect(_games.length).to.equal(1);
            })

            it("placeBets creates a bet and sets game and user", async function() {
                await contract.connect(user1).placeBet(game1, 1, { value: 55 });
                var _bets = await contract.connect(user1).getAllUserBets();
                expect(_bets.length).to.equal(1);
                expect(_bets[0]).to.equal(game1);
            })

            describe("getGameOdds", async function() {
                let game = ethers.utils.formatBytes32String("game with odds");

                before(async function() {
                    await contract.placeBet(game, 1, { value: 1000 })
                    await contract.placeBet(game, 2, { value: 1000 })
                    await contract.placeBet(game, 2, { value: 1000 })
                })

                it("returns odds for every participant", async function() {
                    var odds = await contract.getGameOdds(game);
                    // bet on Draw pays *2
                    expect((odds[0] / 100).toString()).to.equal("2");
                    // bet on Inter pays *1.66
                    expect((odds[1] / 100).toString()).to.equal("1.66");
                    // bet on Milan pays *1.33
                    expect((odds[2] / 100).toString()).to.equal("1.33");
                })
            })
        })
    }) 
});
