import 'package:fluent_ui/fluent_ui.dart';
import 'package:metavision/common/global.dart';
import 'package:webviewx/webviewx.dart';

import 'InfoPage/InfoPanel.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();

}

class _HomePage extends State<HomePage> {
  final viewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      key: viewKey,
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        actions: Row(
          children: [
            const Spacer(),
            WebViewX(
                onWebViewCreated: (controller) => Global.webviewController = controller,
                width: 0,
                height: 0
            )
          ],
        )
      ),
      pane: NavigationPane(
        items:[
          PaneItem(
            icon: const Icon(FluentIcons.account_management),
            title: const Text('我的钱包'),
            body: InfoPanel(),
          ),
        ]
      )
    );
  }
}