import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:metavision/models/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webviewx/webviewx.dart';

import '../models/profile.dart';
import '../wallet/wallet.dart';
import 'utils.dart';

enum TestMode {
  main,
  test
}

const String DefaultSeedPath = "m/44'/0'/0'";

class Global {
  static late SharedPreferences _prefs;
  static late Profile profile;
  static TestMode testMode = TestMode.test;
  static String appVersion = "v0.1.0";
  static Wallet? curWallet;
  static late WebViewXController webviewController;

  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();

    if( testMode == TestMode.test ) {
      appVersion += " - mvctest";
    }

    _prefs = await SharedPreferences.getInstance();
    var _profile = _prefs.getString("profile");
    if (_profile != null) {
      try {
        profile = Profile.fromJson(jsonDecode(_profile));
      } catch (e) {
        debugPrint(e.toString());
      }
    }else{
      profile = const Profile(wallets: [], theme: 0, curWallet: 0);
    }

    debugPrint(profile.toJson().toString());
  }

  static saveProfile() {
    _prefs.setString("profile", jsonEncode(profile.toJson()));
  }

  static Future addWalletFromMnemonic(String mnemonic, {String path = DefaultSeedPath, String password = ""}) async {
    curWallet = Wallet.fromMnenomic(mnemonic, path: path);
    profile = profile.copyWith(wallets: profile.wallets + [WalletProfile(token: ecryptMnemonic(mnemonic, password), seedPath: path, name: "")]);
    profile = profile.copyWith(curWallet: profile.wallets.length - 1);
    saveProfile();
    debugPrint(profile.toJson().toString());

    await curWallet?.getBalance(refresh: true);
  }

  static Future<bool> initWalletFromProfile(int index, String password) async {
    String mnemonic = decryptMnemonic(profile.wallets[index].token, password);
    if( mnemonic.isNotEmpty  ) {
      var seedPath = profile.wallets[index].seedPath;
      curWallet = Wallet.fromMnenomic(mnemonic, path: seedPath);
      profile = profile.copyWith(curWallet: index);
      saveProfile();
      debugPrint(profile.toJson().toString());
      await curWallet?.getBalance(refresh: true);
      return true;
    } else {
      debugPrint(profile.toJson().toString());
      return false;
    }
  }

  static Future<String> genesisNft(int totalSupply, String privKey, {double feeB = 0.5}) async {
    return await webviewController.callJsMethod("genesisNft", ["$totalSupply", privKey, "$feeB"]);
  }

  static Future<String> mintNft(String sensibleID, String metaTxId, String privKey, {double feeB = 0.5}) async {
    return await webviewController.callJsMethod("mintNft", [sensibleID, metaTxId, privKey, "$feeB"]);
  }

  static Future<String> transferNft(String receiverAddress, String codehash, String genesis, int tokenIndex, String privKey, {double feeB = 0.5}) async {
    return await webviewController.callJsMethod("transferNft", [receiverAddress, codehash, genesis, "$tokenIndex", privKey, "$feeB"]);
  }
}