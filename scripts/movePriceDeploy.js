require("dotenv").config();
require("@nomicfoundation/hardhat-ethers");

const hre = require("hardhat");
const { ethers, network } = hre;
const { readRegistry, writeRegistry } = require("./registry");

async function main() {
    const registry = await readRegistry();
    const current = registry[network.name] || {};
    const diamondAddress = process.env.DIAMOND_ADDRESS || current.APSDEX;
    const apsAddress = process.env.APS_ADDRESS || current.APS;

    if (!diamondAddress) {
        throw new Error("Missing DIAMOND_ADDRESS and no APSDEX address in registry");
    }

    if (!apsAddress) {
        throw new Error("Missing APS_ADDRESS and no APS address in registry");
    }

    const movePriceFacet = await ethers.getContractAt("MovePriceFacet", diamondAddress);
    await movePriceFacet.initializeMovePrice(apsAddress, diamondAddress);

    await writeRegistry(network.name, {
        ...current,
        APS: apsAddress,
        APSDEX: diamondAddress,
    });

    console.log("MovePrice facet initialized on diamond:", diamondAddress);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});