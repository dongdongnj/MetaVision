import 'package:fluent_ui/fluent_ui.dart';

import '../models/walletProfile.dart';
import '../wallet/wallet.dart';
import 'global.dart';

class WalletListModel extends ChangeNotifier {
  List<WalletProfile> get wallets => Global.profile.wallets;
  Wallet? get curretWallet => Global.curWallet;
  WalletProfile get curretWalletProfile => Global.profile.wallets[Global.profile.curWallet];

  Future<bool> changeCurWallet(int index, {String password = ""}) async {
    if( index < wallets.length ) {
      bool res = await Global.initWalletFromProfile(index, password);
      notifyListeners();
      return res;
    }
    return false;
  }

  Future addWalletFromMnenomic(String mnemonic, {String path = DefaultSeedPath, String password = ""}) async {
    await Global.addWalletFromMnemonic(mnemonic, path: path, password: password);
    notifyListeners();
  }
}