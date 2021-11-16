const { setConfig } = require('./config.js')

const L7ERC1155 = artifacts.require("L7ERC1155");
const L7ERC1155LazyMint = artifacts.require("L7ERC1155LazyMint");

module.exports = async function (deployer, network) {
    if (network === "mainnet") {
        let mainContract
        let mainContractAddress

        await deployer.deploy(L7ERC1155LazyMint, "");
        mainContract = await L7ERC1155LazyMint.deployed();
        mainContractAddress = await mainContract.address
        console.log("Main contract (ERC1155LazyMint) deployed at address", mainContractAddress)
        setConfig('deployed.' + network + '.L7ERC1155LazyMint', mainContractAddress)
    } else {
        let mainContract
        let mainContractAddress
        await deployer.deploy(L7ERC1155, "");
        mainContract = await L7ERC1155.deployed();
        mainContractAddress = await mainContract.address
        console.log("Main contract (ERC1155) deployed at address", mainContractAddress)
        setConfig('deployed.' + network + '.L7ERC1155', mainContractAddress)

        await deployer.deploy(L7ERC1155LazyMint, "");
        mainContract = await L7ERC1155LazyMint.deployed();
        mainContractAddress = await mainContract.address
        console.log("Main contract (ERC1155LazyMint) deployed at address", mainContractAddress)
        setConfig('deployed.' + network + '.L7ERC1155LazyMint', mainContractAddress)
    }
};