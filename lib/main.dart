import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '/firebase_options.dart';
import '/initial/initial_login.dart';
import '/src/color_palette.dart';
import '/tab/tab_main.dart';
import 'package:shared_preferences/shared_preferences.dart';


main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
