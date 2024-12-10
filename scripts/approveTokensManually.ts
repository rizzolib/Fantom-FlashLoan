// approveTokensManually.ts

import { ethers } from "hardhat";

async function approveTokensManually() {
    const [deployer] = await ethers.getSigners();
    const mimAddress = "0x82f0B8B456c1A451378467398982d4834b6829c1"; // MIM token address
    const lendingPoolAddress = "0x74A0BcA2eeEdf8883cb91E37e9ff49430f20a616"; // BentoBox address

    const mim = await ethers.getContractAt("IERC20", mimAddress);
    const approveTx = await mim.approve(lendingPoolAddress, ethers.utils.parseUnits("1000", 18)); // Approve 1000 MIM tokens
    await approveTx.wait();

    console.log("Successfully approved MIM for LendingPool");
}

approveTokensManually().catch((error) => {
    console.error(error);
    process.exit(1);
});
