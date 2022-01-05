const { expect } = require("chai");
const { ethers } = require("hardhat");
const utils = ethers.utils;

describe("Factory", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Game = await ethers.getContractFactory("Game");
    const proxyGame = await Game.deploy();
    await proxyGame.deployed();

    const Factory = await ethers.getContractFactory("Factory");
    const factory = await Factory.deploy(proxyGame.address);
    await factory.deployed();

    const game = await factory.createGame(utils.formatBytes32String("Name"), [utils.formatBytes32String("one"), utils.formatBytes32String("two"), utils.formatBytes32String("three")], 1234567)
    expect(game).not.to.equal(null);
  });
});
