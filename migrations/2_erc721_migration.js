const { setConfig } = require('./config.js')

const L7NFT = artifacts.require("L7ERC721");
const L7NFTEnum = artifacts.require("L7ERC721Enumerable");
const L7NFTLazyMint = artifacts.require("L7ERC721LazyMint");

module.exports = async function (deployer, network) {
    if (network === 'mainnet') {
        let mainContract
        let mainContractAddress

        await deployer.deploy(L7NFTLazyMint);
        mainContract = await L7NFTLazyMint.deployed();
        mainContractAddress = await mainContract.address
        console.log("Main contract (lazyMint) deployed at address", mainContractAddress)
        setConfig('deployed.' + network + '.L7ERC721LazyMint', mainContractAddress)

    } else {
        let mainContract
        let mainContractAddress

        await deployer.deploy(L7NFT);
        mainContract = await L7NFT.deployed();
        mainContractAddress = await mainContract.address
        console.log("Main contract (ERC721) deployed at address", mainContractAddress)
        setConfig('deployed.' + network + '.L7ERC721', mainContractAddress)

        await deployer.deploy(L7NFTEnum);
        mainContract = await L7NFTEnum.deployed();
        mainContractAddress = await mainContract.address
        console.log("Main contract (ERC721Enumerable) deployed at address", mainContractAddress)
        setConfig('deployed.' + network + '.L7ERC721Enumerable', mainContractAddress)

        await deployer.deploy(L7NFTLazyMint);
        mainContract = await L7NFTLazyMint.deployed();
        mainContractAddress = await mainContract.address
        console.log("Main contract (ERC721LazyMint) deployed at address", mainContractAddress)
        setConfig('deployed.' + network + '.L7ERC721LazyMint', mainContractAddress)
    }
};