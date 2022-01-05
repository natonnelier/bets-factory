// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {

  const Game = await hre.ethers.getContractFactory("Game");
  const proxyGame = await Game.deploy();
  await proxyGame.deployed();

  const Factory = await ethers.getContractFactory("Factory");
  const factory = await Factory.deploy(proxyGame.address);
  await factory.deployed();

  console.log("Factory deployed to:", factory.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });