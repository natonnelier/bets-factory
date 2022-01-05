// We import Chai to use its asserting functions here.
const { expect } = require("chai");
const { tomorrowUnix } = require('./helpers.ts');


describe("Payoutable", function () {

    let Payoutable;
    let contract;
    let owner;
    let user1;
    let user2;


    before(async function () {
        Payoutable = await ethers.getContractFactory("Payoutable");
        [owner, user1, user2, user3] = await ethers.getSigners();

        contract = await Payoutable.deploy();
    });

    // Test owner and deployment.
    describe("Deployment", function () {

        it("Should set the right owner", async function () {
            expect(await contract.owner()).to.equal(owner.address);
        })
    });

    // Test checkout and prize pay
    describe("checkStatusAndPay function", function() {
        // pay prizes
        describe("when Game has winner set and status is completed", function() {
            let winningTotal;
            let losingTotal;
            
            describe("if one winner gets the whole pot", function() {
                let game = ethers.utils.formatBytes32String("Santos vs Flamengo");
                let losingBet = 8000;
                let winningBet = 6000;

                before(async function() {    
                    // user places Bet on 2
                    await contract.connect(user1).placeBet(game, 2, { value: winningBet });
    
                    // admin places Bet on 1
                    await contract.connect(user2).placeBet(game, 1, { value: losingBet });
                })
    
                it("it pays prizes properly to winner", async function() {
                    winningTotal = winningBet;
                    losingTotal = losingBet;

                    const subtotal = winningBet + losingTotal * winningBet / winningTotal;

                    //calculate house share
                    const houseShare = subtotal / 100;

                    //calculate final prize for user
                    const prize = subtotal - houseShare;

                    const tx = await contract.checkStatusAndPay(game, 2);
    
                    // check emited events content
                    const res = await tx.wait();
                    const event = res.events[0];
    
                    // check values in broadcasted events
                    expect(event.args.message).to.equal("Prize sent to user address");
                    expect(event.args.user).to.equal(user1.address);
                    expect(event.args.amount).to.equal(prize);
                })
            })

            describe("if multiple winners share the prize", function() {
                let game = ethers.utils.formatBytes32String("Boca vs River");
                let losingBet = 8000;
                let winningBet1 = 6000;
                let winningBet2 = 4000;

                before(async function() {    
                    // user places Bet on Arsenal
                    await contract.connect(user1).placeBet(game, 2, { value: winningBet1 });

                    // user places Bet on Arsenal
                    await contract.connect(user3).placeBet(game, 2, { value: winningBet2 });
    
                    // admin places Bet on Chelsea
                    await contract.connect(user2).placeBet(game, 1, { value: losingBet });
                })
    
                it("it pays prizes properly to each winner", async function() {
                    winningTotal = winningBet1 + winningBet2;
                    losingTotal = losingBet;

                    const subtotal1 = winningBet1 + losingTotal * winningBet1 / winningTotal;
                    const subtotal2 = winningBet2 + losingTotal * winningBet2 / winningTotal;

                    //calculate house share
                    const houseShare1 = subtotal1 / 100;
                    const houseShare2 = subtotal2 / 100;

                    //calculate final prize for user
                    const prize1 = subtotal1 - houseShare1;
                    const prize2 = subtotal2 - houseShare2;

                    const tx = await contract.checkStatusAndPay(game, 2);
    
                    // check emited events content
                    const res = await tx.wait();
    
                    // check values in broadcasted events for first winner user1
                    expect(res.events[0].args.message).to.equal("Prize sent to user address");
                    expect(res.events[0].args.user).to.equal(user1.address);
                    expect(res.events[0].args.amount).to.equal(prize1);
    
                    // check values in broadcasted events for second winner user3
                    expect(res.events[1].args.message).to.equal("Prize sent to user address");
                    expect(res.events[1].args.user).to.equal(user3.address);
                    expect(res.events[1].args.amount).to.equal(prize2);
                })
            })
        })
    }) 
});
