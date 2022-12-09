import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class MnemonicInput extends StatefulWidget{
  String? mnemonic;
  bool Function(String mnemonic, {String seedPath, String password}) onOK;

  MnemonicInput({super.key, required this.onOK, this.mnemonic});

  @override
  _MnemonicInput createState() => _MnemonicInput();
}

class _MnemonicInput extends State<MnemonicInput> {
  String _mnemonic = "";
  String _password = "";
  String _seedPath = "m/44'/0'/0'";
  bool _isPasswordCanSee = false;

  @override
  void initState() {
    super.initState();
    _mnemonic = widget.mnemonic ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("导入钱包"),
      content: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            TextBox(
              initialValue: _mnemonic,
              header: "助记词:",
              maxLines: 3,
              onChanged: (mne){
                _mnemonic = mne;
              },
            ),
            const SizedBox(height: 5,),
            TextBox(
              header: "衍生路径:",
              maxLines: 1,
              initialValue: _seedPath,
              onChanged: (path){
                _seedPath = path;
              },
            ),
            const SizedBox(height: 5,),
            TextBox(
              header: "锁定密码:",
              obscureText: !_isPasswordCanSee,
              onChanged: (v){
                _password = v;
              },
              suffix: IconButton(
                icon: _isPasswordCanSee ? const Icon(material.Icons.visibility) : const Icon(material.Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _isPasswordCanSee = !_isPasswordCanSee;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        Button(
          child: const Text("返回"),
          onPressed: () {
            Navigator.pop(context);
          }
        ),
        Button(
          child: const Text("确定"),
          onPressed: () async {
            if(!bip39.validateMnemonic(_mnemonic)) {
              SmartDialog.showToast("助记词无效");
            } else {
              SmartDialog.showLoading(msg: "正在导入");
              try {
                bool res = widget.onOK(_mnemonic, password: _password, seedPath: _seedPath);
                SmartDialog.dismiss();

                if( res ) {
                  Navigator.pop(context);
                } else {
                  SmartDialog.showToast("导入失败", displayTime: const Duration(seconds: 5));
                }
              } catch(e) {
                debugPrint(e.toString());
                SmartDialog.dismiss();
                SmartDialog.showToast("导入失败", displayTime: const Duration(seconds: 5));
              }
            }
          }
        )
      ],
    );
  }
}