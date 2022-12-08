import 'package:encrypt/encrypt.dart';

const String PassKey = "11111111111111111111111111111111";

String ecryptMnemonic(String mnemonic, String password) {
  var passKey = "";
  if( password.isNotEmpty ) {
    passKey = PassKey.replaceRange(0, password.length - 1, password);
  } else {
    passKey = PassKey;
  }
  final key = Key.fromUtf8(passKey);
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));
  final encrypted = encrypter.encrypt(mnemonic, iv: iv);
  return encrypted.base64;
}

String decryptMnemonic(String encrypted, String password) {
  var passKey = "";
  if( password.isNotEmpty ) {
    if( password.length == PassKey.length ) {
      passKey = password;
    } else {
      passKey = PassKey.replaceRange(0, password.length, password);
    }
  } else {
    passKey = PassKey;
  }

  final key = Key.fromUtf8(passKey);
  final iv = IV.fromLength(16);
  try {
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt64(encrypted, iv: iv);
    return decrypted;
  } catch (e) {
    return "";
  }
}