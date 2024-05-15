const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");

describe("Presale Vesting Smart Contract", function () {
    async function deployKCFContract() {

        // Contracts are deployed using the first signer/account by default
        const [deployer] = await ethers.getSigners();

        const KCFToken = await ethers.getContractFactory("PreSaleVesting");
        const kcfTokenInstance = await KCFToken.deploy(deployer.address, deployer.address, deployer.address, deployer.address );

        return { kcfTokenInstance, deployer };
    }

    describe("Deployment", function () {
        it("Should assign the deployer of tokens to the owner", async function () {
            const { kcfTokenInstance, deployer } = await deployKCFContract();
            console.log(deployer.address, "right");
            console.log(await kcfTokenInstance.owner(), "left");
            expect(await kcfTokenInstance.owner()).to.equal(deployer.address);
        });
    });
});
