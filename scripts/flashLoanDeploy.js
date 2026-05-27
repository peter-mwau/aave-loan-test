require("dotenv").config();
require("@nomicfoundation/hardhat-ethers");

const hre = require("hardhat");
const { ethers, network } = hre;
const { readRegistry, writeRegistry } = require("./registry");

async function deployLocalMockPool() {
    const MockPool = await ethers.getContractFactory("MockPool");
    const mockPool = await MockPool.deploy({ gasLimit: 2_000_000 });
    await mockPool.waitForDeployment();
    return await mockPool.getAddress();
}

async function main() {
    const registry = await readRegistry();
    const current = registry[network.name] || {};
    const diamondAddress = process.env.DIAMOND_ADDRESS || current.APSDEX;

    if (!diamondAddress) {
        throw new Error("Missing DIAMOND_ADDRESS and no APSDEX address in registry");
    }

    const flashLoanPool = process.env.FLASH_LOAN_POOL_ADDRESS
        ? ethers.getAddress(process.env.FLASH_LOAN_POOL_ADDRESS)
        : (network.name === "localhost" || network.name === "hardhat")
            ? await deployLocalMockPool()
            : null;

    if (!flashLoanPool) {
        throw new Error("Missing FLASH_LOAN_POOL_ADDRESS for this network");
    }

    const flashLoanFacet = await ethers.getContractAt("FlashLoanFacet", diamondAddress);
    await flashLoanFacet.initializeFlashLoan(flashLoanPool);

    await writeRegistry(network.name, {
        ...current,
        APSDEX: diamondAddress,
        FlashLoanPool: flashLoanPool,
    });

    console.log("FlashLoan facet initialized on diamond:", diamondAddress);
    console.log("Flash loan pool:", flashLoanPool);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});