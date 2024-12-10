// interact.ts

import { ethers } from "hardhat";

async function interactWithContract() {
    const [deployer] = await ethers.getSigners();
    console.log("Interacting with contract using account:", deployer.address);

    // Replace with your actual contract address
    const contractAddress = "0x0092fb63970a65bEB3E9dc526b9b7eC9E04ce5aD";  // Use your contract address
    const FlashLoanResearch = await ethers.getContractFactory("FlashLoanResearch");
    const contract = await FlashLoanResearch.attach(contractAddress);

    // const MIM_ADDRESS = "0x82f0B8B456c1A451378467398982d4834b6829c1";
    // const mimAmount = ethers.utils.parseUnits("0.1", 18);

    // const mim = await ethers.getContractAt("IERC20", MIM_ADDRESS);
    // const approveTx = await mim.approve(contractAddress, ethers.utils.parseUnits("1000", 18)); // Approve 1000 MIM tokens
    // await approveTx.wait();
    // console.log("MIM approved to your contract successfully.");

    // Example: Initiate the Flash Loan
    const amount = ethers.utils.parseUnits("1000", 18); // Example MIM amount
    console.log("Initiating flash loan...");
    const tx = await contract.initiateFlashLoan(amount, {
        gasLimit: 500000,  // Try setting a specific gas limit
    });
    console.log("Flash loan transaction sent. Tx Hash:", tx.hash);

    // Wait for the transaction to be mined
    const receipt = await tx.wait();
    console.log("Flash loan transaction receipt:", receipt);

}

// Start interacting with the contract
interactWithContract()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
