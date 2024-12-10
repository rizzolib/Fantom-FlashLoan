import { ethers } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Using account:", deployer.address);

    // Define token and spender addresses
    const MIM = "0x82f0B8B456c1A451378467398982d4834b6829c1"; // MIM token address
    const BENTO_BOX = "0xF5BCE5077908a1b7370B9ae04AdC565EBd643966"; // BentoBox address
    const LENDING_POOL = "0x74A0BcA2eeEdf8883cb91E37e9ff49430f20a616"; // LendingPool address

    // Create an ERC20 instance for MIM
    const mim = await ethers.getContractAt("IERC20", MIM);

    // Check allowance from the contract (deployer address) to BentoBox
    const allowanceBentoBox = await mim.allowance(deployer.address, BENTO_BOX);
    console.log("Allowance for BentoBox:", ethers.utils.formatUnits(allowanceBentoBox, 18));

    // Check allowance from the contract (deployer address) to LendingPool
    const allowanceLendingPool = await mim.allowance(deployer.address, LENDING_POOL);
    console.log("Allowance for LendingPool:", ethers.utils.formatUnits(allowanceLendingPool, 18));

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

