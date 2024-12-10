import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-ethers";
import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.28", // Ensure Solidity version matches your contract
  networks: {
    fantom: {
      url: `https://rpcapi.fantom.network`,  // Fantom mainnet RPC URL
      accounts: [`0x${process.env.PRIVATE_KEY}`], // Private key from .env
      chainId: 250, // Fantom Opera Chain ID
    },
  },
};

export default config;