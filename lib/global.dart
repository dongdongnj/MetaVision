import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/index.dart';
import '../service/mvcMetafileId.dart';
import '../service/mvcShowmoney.dart';
import '../wallet/metaidwallet.dart';
import 'fileSendWorker.dart';

class Global {
  static late SharedPreferences _prefs;
  static Profile profile = Profile();
  static MetaidWallet? wallet;
  static List<MetafileIdFileInfo> fileList = [];
  static String appVersion = "v0.5.0 - mvctest";
  // static FileSendFactory fileSendFactory = FileSendFactory();
  // static FileSender fileSender = FileSender();
  static List<FileSendWorker> fileSenderWorkerList = [];

  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();

    _prefs = await SharedPreferences.getInstance();
    var _profile = _prefs.getString("profile");
    if (_profile != null) {
      try {
        profile = Profile.fromJson(jsonDecode(_profile));
      } catch (e) {
        print(e);
      }
    }else{
      profile= Profile()..theme=0;
    }

    profile.cache = profile.cache ?? CacheConfig()
      ..enable = true
      ..maxAge = 3600
      ..maxCount = 100;

    // await initUserInfo();
    if(profile.downLoadDir == null || profile.downLoadDir!.isEmpty) {
      profile.downLoadDir = (await getDownloadsDirectory())?.path;
    }
    debugPrint(profile.toJson().toString());

    // await fileSender.init();
  }

  static saveProfile() {
    _prefs.setString("profile", jsonEncode(profile.toJson()));
  }

  static Future clearPrefs() async {
    profile = Profile();
    await _prefs.clear();
  }

  static Future updateFileList() async {
    if( wallet != null && profile.metaid != null && profile.metaid!.isNotEmpty ) {
      List<MetafileIdFileInfo> list = [];
      List<MetafileIdFileInfo> tmplist = await MvcMetafileId.queryFileByMetaid(profile.metaid!);
      list.addAll(tmplist);

      int limit = 100;
      while(tmplist.length == limit) {
        tmplist = await MvcMetafileId.queryFileByMetaid(profile.metaid!, offset:list.length, limit:limit);
        list.addAll(tmplist);
      }

      fileList.clear();
      fileList = list;
    }
  }

  static notNeedLogin() {
    return profile.metaid != null && profile.metaid!.isNotEmpty &&
        profile.metaidNodes?.rootNode?.txid != null && profile.metaidNodes!.rootNode!.txid!.isNotEmpty &&
        profile.metaidNodes?.metafileNode?.txid != null && profile.metaidNodes!.metafileNode!.txid!.isNotEmpty &&
        profile.metaidNodes?.metafileNode?.pathIndex != null &&
        profile.token != null && profile.token!.isNotEmpty;
  }

  static isValidMetaidInfo() {
    return wallet != null &&
          profile.metaid != null && profile.metaid!.isNotEmpty &&
          profile.metaidNodes?.rootNode?.txid != null && profile.metaidNodes!.rootNode!.txid!.isNotEmpty &&
          profile.metaidNodes?.metafileNode?.txid != null && profile.metaidNodes!.metafileNode!.txid!.isNotEmpty &&
          profile.metaidNodes?.metafileNode?.pathIndex != null &&
          profile.token != null && profile.token!.isNotEmpty;
  }

  static Future initWalletFromNewMnemonic(String mnemonic, String path, String password) async {
    wallet = MetaidWallet();
    await wallet?.initByMnemonic(mnemonic, path: path);
    profile.token = Global.wallet?.ecryptMnemonic(mnemonic, password);
    profile.seedPath = path;
    await wallet?.updateUnspents();
    saveProfile();

    debugPrint(profile.toJson().toString());
  }

  static Future initMetaid() async {
    MetaidNodes? metaidNodes = await Global.wallet?.initMetaid();
    profile.metaid = metaidNodes?.rootNode?.txid;
    profile.metaidNodes = metaidNodes;

    saveProfile();
    debugPrint(profile.toJson().toString());
  }

  static Future<bool> initWalletFromProfile(String password) async {
    wallet = MetaidWallet();
    var mnemonic = wallet?.decryptMnemonic(profile.token!, password);
    if( mnemonic != null  ) {
      var seedPath = profile.seedPath ?? "m/44'/0'/0'";
      await wallet?.initByMnemonic(mnemonic, path: seedPath);
      wallet?.initMetaFileWallet(profile.metaidNodes!.metafileNode!);
      await wallet?.updateUnspents();
    }

    debugPrint(profile.toJson().toString());
    return isValidMetaidInfo();
  }

  static Future<bool> initWalletFromOldMnemonic(String mnemonic, String path, String password) async {
    wallet = MetaidWallet();
    await wallet?.initByMnemonic(mnemonic, path: path);

    profile.metaid = await MvcShowMoneyServiceapi.getMetaIdByZoreAddress(wallet!.zeroAddress);

    MetaidNodes metaidNodes = MetaidNodes();
    metaidNodes.rootNode=MetaidNodeInfo()..pathIndex=0..txid=profile.metaid;
    profile.metaidNodes = metaidNodes;
    profile.token = Global.wallet?.ecryptMnemonic(mnemonic, password);
    profile.seedPath = path;

    // if( profile.metaid != null && profile.metaid!.isNotEmpty ) {
    //   MvcUserInfo? userInfo = await MvcShowMoneyServiceapi.getUserInfo(profile.metaid!);
    //   debugPrint(userInfo?.toJson().toString());
    //   if( userInfo?.protocolTxId != null ) {
    //     List<String> metaFileNodePk = await MvcShowMoneyServiceapi.getProtocolDataList(userInfo!.protocolTxId!, "MetaFile");
    //     debugPrint(metaFileNodePk.toString());
    //     if( metaFileNodePk.isNotEmpty ) {
    //       int? pathIndex = wallet?.initMetafileWalletByPubKey(metaFileNodePk[0]);
    //       if(pathIndex != null) {
    //         metaidNodes.metafileNode = MetaidNodeInfo()..pathIndex=pathIndex..txid=metaFileNodePk[1];
    //         wallet?.initMetaFileWallet(profile.metaidNodes!.metafileNode!);
    //         await wallet?.updateUnspents();
    //       }
    //     }
    //   }
    // }

    saveProfile();
    debugPrint(profile.toJson().toString());

    return isValidMetaidInfo();
  }
}