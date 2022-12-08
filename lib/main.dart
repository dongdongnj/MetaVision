import 'package:fluent_ui/fluent_ui.dart' hide Page;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

import 'common/global.dart';
import 'common/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();

  Global.init().then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: AppTheme()),
        ],
        builder: (context, _) {
          final appTheme = context.watch<AppTheme>();
          return FluentApp(
            // title: appTitle,
            // showPerformanceOverlay: true,
            themeMode: appTheme.mode,
            debugShowCheckedModeBanner: false,
            color: appTheme.color,
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              accentColor: appTheme.color,
              visualDensity: VisualDensity.standard,
              focusTheme: FocusThemeData(
                glowFactor: is10footScreen() ? 2.0 : 0.0,
              ),
            ),
            theme: ThemeData(
              accentColor: appTheme.color,
              visualDensity: VisualDensity.standard,
              focusTheme: FocusThemeData(
                glowFactor: is10footScreen() ? 2.0 : 0.0,
              ),
              fontFamily: "Noto Sans SC",
            ),
            locale: appTheme.locale,
            builder:  FlutterSmartDialog.init(
                builder: (context, child) {
                  return Directionality(
                    textDirection: appTheme.textDirection,
                    child: NavigationPaneTheme(
                      data: const NavigationPaneThemeData(
                        backgroundColor: Colors.transparent,
                      ),
                      child: child!,
                    ),
                  );
                }
            ),
            // initialRoute: Global.notNeedLogin() ? 'profileAccount' : 'login',
            routes: {

            },
          );
        }
    );
  }
}

