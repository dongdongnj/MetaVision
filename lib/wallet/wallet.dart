import 'package:dartsv/dartsv.dart';
import 'package:bip39/bip39.dart' as bip39;

import '../service/mvcMetasv.dart';
import '../service/utils.dart';

Map<NetworkType, String> ChainStr = {
  NetworkType.MAIN: Chain.MAIN,
  NetworkType.TEST: Chain.TEST,
};

class Wallet {
  static NetworkType chain = NetworkType.TEST;
  late SVPrivateKey key;
  List<TransactionOutput> unspents = [];

  Wallet(this.key);

  String get networkType => ChainStr[key.networkType] ?? Chain.MAIN;
  String get address => key.toAddress().toString();


  Wallet.fromMnenomic(String mnemonic, {String path = "m/44'/0'/0'", String passphrase = "/0"}) {
    var seedVector = bip39.mnemonicToSeedHex(mnemonic);
    var accountKey = HDPrivateKey.fromXpriv(HDPrivateKey.fromSeed(seedVector, chain).xprivkey);

    HDPrivateKey xprivateKey = accountKey.deriveChildKey(path);
    xprivateKey.networkType = chain;
    key = xprivateKey.privateKey;
  }

  Future<List<TransactionOutput>> getUnspent({bool refresh = false}) async {
    if (refresh) {
      unspents = await MvcMetaSV.get_unspent(address);
    }
    return unspents;
  }

  int get balance {
    int balance = 0;
    for (var unspent in unspents) {
      balance += unspent.satoshis.toInt();
    }
    return balance;
  }

  Future<int> getBalance({bool refresh = false}) async {
    if (refresh) {
      await getUnspent(refresh: true);
    }

    return balance;
  }

  static String generateMnenomic() {
    return bip39.generateMnemonic();
  }
}