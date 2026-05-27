const { expect } = require("chai");
const { ethers } = require("hardhat");
const { deployDiamondFixture } = require("./helpers/deployDiamond");

let fixture;
let aps;
let flashLoan;
let ownership;
let owner;
let diamondAddress;
let mockPool;

beforeEach(async function () {
    fixture = await deployDiamondFixture();
    ({ aps, flashLoan, ownership, owner, diamondAddress, mockPool } = fixture);
});

describe("Deployment", function () {
    it("should set the right owner", async function () {
        expect(await ownership.owner()).to.equal(owner.address);
    });
});

describe("Flash Loan", function () {
    it("should store the pool address and allow a request", async function () {
        await expect(flashLoan.requestFlashLoanSimple(ethers.ZeroAddress, ethers.parseEther("1"))).to.not.be.reverted;
    });

    it("should let the owner withdraw funds from the diamond", async function () {
        const amount = ethers.parseEther("10");
        await aps.connect(owner).transfer(diamondAddress, amount);

        const before = await aps.balanceOf(owner.address);
        await flashLoan.connect(owner).withdrawFunds(await aps.getAddress());
        const after = await aps.balanceOf(owner.address);

        expect(after - before).to.equal(amount);
    });
});
