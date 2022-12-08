function generateMnenomic() {
    return metaContract.mvc.Mnemonic.fromRandom();
}

async function genesisNft(totalSupply, privKey, feeB) {
    let nftManager = new NftManager({apiTarget: API_TARGET.MVC, network: API_NET.TEST, purse: privKey, feeb: feeB});
    return await nftManager.genesis({totalSupply: totalSupply.toString()});
}

async function mintNft(sensibleID, metaTxId, privKey, feeB) {
    let nftManager = new NftManager({apiTarget: API_TARGET.MVC, network: API_NET.TEST, purse: privKey, feeb: feeB});
    return await nftManager.mint({
        metaOutputIndex: 0,
        metaTxId: metaTxId,
        sensibleId: sensibleID
    });
}

async function transferNft(receiverAddress, codehash, genesis, tokenIndex, privKey, feeB) {
    let nftManager = new NftManager({apiTarget: API_TARGET.MVC, network: API_NET.TEST, purse: privKey, feeb: feeB});
    return await nftManager.transfer({
        codehash: codehash,
        genesis: genesis,
        receiverAddress: receiverAddress,
        senderWif: privKey,
        tokenIndex: tokenIndex.toString()
    });
}