import 'package:dropdown_search/dropdown_search.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:metavision/common/global.dart';
import 'package:metavision/dialog/mnenomicInput.dart';
import 'package:metavision/wallet/wallet.dart';
import 'package:provider/provider.dart';

import '../../common/WalletListModel.dart';
import '../../models/walletProfile.dart';

class InfoPanel extends StatefulWidget {
  @override
  _InfoPage createState() => _InfoPage();
}

class _InfoPage extends State<InfoPanel> {
  late WalletListModel _walletList;

  @override
  Widget build(BuildContext context) {
    _walletList = Provider.of<WalletListModel>(context);

    return ScaffoldPage(
      content: _getContent(),
      bottomBar: _bottomContent(),
    );
  }

  _getContent() {
    return Center(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              child: _walletList.wallets.isNotEmpty ? DropdownSearch<WalletProfile>(
                selectedItem: _walletList.curretWalletProfile,
                itemAsString: (WalletProfile info){
                  return info.name.isEmpty ? "Wallet" : info.name;
                },
                items: _walletList.wallets,
                popupProps: const PopupProps.menu(
                  showSearchBox: false,
                  fit: FlexFit.loose,
                  constraints: BoxConstraints(maxHeight: 300),
                ),
                onChanged: (value){
                  if( value == null ) return;

                  int index = _walletList.wallets.indexOf(value);
                  _walletList.changeCurWallet(index);
                },
              ) : const Text("没有可用的钱包"),
            )
            ,
            Container(
              margin: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SelectableText("${_walletList.curretWallet?.address}"),
                      IconButton(
                        icon: const Icon(FluentIcons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _walletList.curretWallet?.address));
                        }
                      )
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      const Spacer(),
                      Text("$_balance SPACE")
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  bool _onMnemonicInput(String mnemonic, {String seedPath = DefaultSeedPath, String password=""}) {
    _walletList.addWalletFromMnenomic(mnemonic, path: seedPath, password: password);
    return true;
  }

  _bottomContent() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Button(child: const Text("新建钱包"), onPressed: (){
            showDialog(
              context: context, builder: (_) => MnemonicInput(onOK: _onMnemonicInput, mnemonic: Wallet.generateMnenomic(),),
            );
          }),
          const SizedBox(width: 5,),
          Button(child: const Text("导入钱包"), onPressed: (){
            showDialog(
              context: context, builder: (_) => MnemonicInput(onOK: _onMnemonicInput),
            );
          }),
        ],
      ),
    );
  }

  String get _balance {
    double balance = 0.00000000;

    balance = (_walletList.curretWallet?.balance.toDouble() ?? 0.00000000) / 100000000;

    return balance.toString();
  }
}