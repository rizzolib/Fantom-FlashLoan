// deploy.ts

import { ethers } from "hardhat";

async function main() {
    // Get the signer (deployer) to deploy the contract
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    // Get the contract factory for your contract
    const FlashLoanResearch = await ethers.getContractFactory("FlashLoanResearch");

    // Deploy the contract
    const flashLoanContract = await FlashLoanResearch.deploy();
    console.log("FlashLoanResearch contract deployed to:", flashLoanContract.address);

    // Optionally, approve tokens if needed
    console.log("Approving tokens...");
    const approveTx = await flashLoanContract.approveTokensManually();
    await approveTx.wait();  // Wait for the transaction to be mined
    console.log("Tokens approved successfully.");
}

// Start the deployment process
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

