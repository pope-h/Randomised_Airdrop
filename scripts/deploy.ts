import { ethers } from "hardhat";

async function main() {
  const subscriptionId = 9806;

  const guessingGame = await ethers.deployContract("GuessingGame", [subscriptionId]);

  await guessingGame.waitForDeployment();

  console.log(
    `GuessingGame contract deployed to ${guessingGame.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
