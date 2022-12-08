import 'package:dartsv/dartsv.dart';
import 'package:dio/dio.dart';

import 'utils.dart';

class MvcMetaSV {
  static Dio dio = Dio(BaseOptions(
      baseUrl:'https://api-mvc-testnet.metasv.com',
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json', },
      connectTimeout: 10000,
      // receiveTimeout: 30000,
      // sendTimeout: 30000,
  ));

  static Future<List<TransactionOutput>> get_unspent(String address) async {
    var res = await dio.get("/address/$address/utxo");
    var scriptBuilder = P2PKHLockBuilder(Address.fromBase58(address));
    // debugPrint(res.data.toString());
    return (res.data as List<dynamic>).map((e) => TransactionOutput(scriptBuilder: scriptBuilder)
      ..satoshis = BigInt.from(e['value'] ?? 0)
      ..transactionId = e['txid']
      ..outputIndex = e['outIndex'])
      .toList();
  }

  static Future<BroadcastResult> broadcast(String rawTx) async {
    var data = {'hex': rawTx};
    BroadcastResult broadcastResult = BroadcastResult(false, "");
    try{
      var res = await dio.post("/tx/broadcast", data: data);
      if( (res.statusCode == 200 || res.statusCode == 201) && res.data['txid'] != null ) {
        broadcastResult.msg = res.data['txid'];
        broadcastResult.propagated = true;
      } else {
        broadcastResult.msg = res.data['message'];
        broadcastResult.propagated = false;
      }
    } catch (e) {
      broadcastResult.msg = e.toString();
      broadcastResult.propagated = false;
    }

    // if( !broadcastResult.propagated ) {
    //   for( int index = 0; index < 3; index++ ) {
    //     broadcastResult = await retry_broadcast(rawTx);
    //     debugPrint("retry_broadcast $index ${broadcastResult.msg}");
    //     if( broadcastResult.propagated ) break;
    //   }
    // }
    print(broadcastResult.msg);
    return broadcastResult;
  }

  static Future<BroadcastResult> retry_broadcast(String rawTx) async {
    var data = {'hex': rawTx};
    BroadcastResult broadcastResult = BroadcastResult(false, "");
    try{
      var res = await dio.post("/tx/raw", data: data);
      if( res.statusCode == 200 || res.statusCode == 201 ) {
        broadcastResult.msg = res.data['txid'];
        broadcastResult.propagated = true;
      } else {
        broadcastResult.msg = res.data['message'];
        broadcastResult.propagated = false;
      }
    } catch (e) {
      broadcastResult.msg = e.toString();
      broadcastResult.propagated = false;
    }
    return broadcastResult;
  }
}