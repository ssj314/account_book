import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_common.dart';
import 'package:money_won/firebase_options.dart';
import 'package:money_won/initial/initial_login.dart';
import 'package:money_won/initial/initial_main.dart';
import 'package:money_won/src/color_palette.dart';
import 'package:money_won/tab/tab_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // KakaoSdk.init(
  //   nativeAppKey: "bd1366bf9fa6aac72e702889b9ba1984",
  //   javaScriptAppKey: "ba1d4601b9f9d23fef609b87ab861260"
  // );
  runApp(MoneyWon());
}


class MoneyWon extends StatelessWidget {
  MoneyWon({super.key});
  final palette = ColorPalette();


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '가계부',
      debugShowCheckedModeBanner: false,
      color: palette.of(context).background,
      theme: ThemeData(
        colorSchemeSeed: Colors.blueAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity
      ),
      home: const StartPage()
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPage();
}

class _StartPage extends State<StartPage> {
  final palette = ColorPalette();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: isInitialRun(),
        builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.waiting) {
            if(snapshot.hasData) {
              if(snapshot.data as bool) {
                return InitialLoginPage();
              } else {
                return Container(color: palette.of(context).background, padding: const EdgeInsets.only(bottom: 24), child: const TabMain());
              }
            }
          }
          return Container(
              color: palette.of(context).background,
              child: SpinKitFadingCube(color: palette.of(context).indicatorColor)
          );
        }

    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  isInitialRun() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool("initial-run") ?? true;
  }
}
