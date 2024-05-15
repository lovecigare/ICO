const { ethers } = require("hardhat");

async function main() {

    const [deployer] = await ethers.getSigners();
    const deployerAddress = await deployer.getAddress();
    const message0 = 'Deploying KronletCashFrancToken with address: ' + deployerAddress;
    console.log(message0);
    //////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////
  
    const KCFToken = await ethers.getContractFactory('KronletCashFrancToken');
    const KCFtokenFactory = await KCFToken.deploy();
  
    await KCFtokenFactory.deployed();
    const KCFtokenFactoryAddress = KCFtokenFactory.address
    console.log('KronletCashFrancToken contract deployed at', KCFtokenFactoryAddress);


    //////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////
    const message1 = 'Deploying the KronletFrancToken: ' + deployerAddress;
    console.log(message1);

    const KFToken = await ethers.getContractFactory('KronletCashFrancToken');
    const KFtokenFactory = await KFToken.deploy();
  
    await KFtokenFactory.deployed();
    const KFtokenFactoryAddress = KFtokenFactory.address
    console.log('KronletFrancToken contract deployed at', KFtokenFactoryAddress);
  }
  
  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  