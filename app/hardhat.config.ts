import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

dotenv.config();

// プライベートキーの形式を正規化
const getPrivateKey = () => {
  if (!process.env.PRIVATE_KEY) return [];
  const key = process.env.PRIVATE_KEY;
  return [key.startsWith('0x') ? key : `0x${key}`];
};

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    amoy: {
      url: "https://rpc-amoy.polygon.technology",
      accounts: getPrivateKey(),
      chainId: 80002
    },
    sepolia: {
      url: "https://ethereum-sepolia-rpc.publicnode.com",
      accounts: getPrivateKey(),
      chainId: 11155111
    },
    polygon: {
      url: "https://polygon-rpc.com",
      accounts: getPrivateKey(),
      chainId: 137
    }
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY || ""
    }
  }
};

export default config;
