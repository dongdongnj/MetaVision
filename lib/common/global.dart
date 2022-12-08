import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webviewx/webviewx.dart';

import '../models/profile.dart';
import '../wallet/wallet.dart';
import 'utils.dart';

enum TestMode {
  main,
  test
}

String DefaultSeedPath = "m/44'/0'/0'";

class Global {
  static late SharedPreferences _prefs;
  static late Profile profile;
  static TestMode testMode = TestMode.test;
  static String appVersion = "v0.1.0";
  static late Wallet wallet;
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
        print(e);
      }
    }else{
      profile= Profile(token: "", seedPath: DefaultSeedPath, theme: 0);
    }

    debugPrint(profile.toJson().toString());
  }

  static saveProfile() {
    _prefs.setString("profile", jsonEncode(profile.toJson()));
  }

  static Future clearPrefs() async {
    profile = Profile(token: "", seedPath: DefaultSeedPath, theme: 0);
    await _prefs.clear();
  }


  static notNeedLogin() {
    return profile.token != null && profile.token!.isNotEmpty;
  }

  static Future initWalletFromNewMnemonic(String mnemonic, String path, String password) async {
    wallet = Wallet.fromMnenomic(mnemonic, path: path);
    profile = profile.copyWith(token: ecryptMnemonic(mnemonic, password), seedPath: path);
    saveProfile();
    debugPrint(profile.toJson().toString());
  }

  static Future<bool> initWalletFromProfile(String password) async {
    String mnemonic = decryptMnemonic(profile.token!, password);
    if( mnemonic.isNotEmpty  ) {
      var seedPath = profile.seedPath;
      wallet = Wallet.fromMnenomic(mnemonic, path: seedPath);
      debugPrint(profile.toJson().toString());
      return true;
    } else {
      debugPrint(profile.toJson().toString());
      return false;
    }
  }

  static Future initWalletFromOldMnemonic(String mnemonic, String path, String password) async {
    wallet = Wallet.fromMnenomic(mnemonic, path: path);
    profile = profile.copyWith(token: ecryptMnemonic(mnemonic, password), seedPath: path);

    saveProfile();
    debugPrint(profile.toJson().toString());
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