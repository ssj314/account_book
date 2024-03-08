import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '/fn/account_manager.dart';
import '/fn/simple_account_manager.dart';
import '/fn/user_manager.dart';
import '/src/color_palette.dart';
import '/src/system_value.dart';
import '/tab/tab_home.dart';
import '/tab/tab_menu.dart';
import '/tab/tab_summary.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TabMain extends StatefulWidget {
  const TabMain({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TabMain();
  }
}

class _TabMain extends State<TabMain> {
  final value = SystemValue();
  final palette = ColorPalette();

  late final UserManager user;
  late final dynamic account;
  late final String uid;
  late final String platform;

  late dynamic futureVar;
  var tabValue = 1;
  String errMsg = "Error! Please restart the app.";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureVar,
        builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.waiting) {
            if(snapshot.hasData && snapshot.data as bool) {
              return Container(
                color: palette.of(context).background,
                child: _buildTabBarScaffold()
              );
            } else {
              _deletePreferences();
              return Container(
                  color: Colors.black,
                  child: Center(
                      child: Text(errMsg,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: value.title3
                          )
                      )
                  )
              );
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
    futureVar = _getAccount();
  }

  _buildTabBarScaffold() {
    var tabItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.table_chart)),//, label: "요약",),
      const BottomNavigationBarItem(icon: Icon(Icons.home_filled)),//, label: "홈"),
      const BottomNavigationBarItem(icon: Icon(CupertinoIcons.square_grid_2x2_fill)),//, label: "메뉴")
    ];
    var tabs = [
      SummaryPage(user: user),
      HomePage(user: user, account: account),
      MenuPage(user: user, account: account)
    ];

    return Scaffold(
        backgroundColor: palette.of(context).background,
        bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
                canvasColor: palette.of(context).background,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent
            ),
            child: Container(
                //padding: const EdgeInsets.only(bottom: 28),
                child: CupertinoTabBar(
                  items: tabItems,
                  currentIndex: tabValue,
                  activeColor: palette.of(context).complementary,
                  inactiveColor: palette.of(context).secondary,
                  backgroundColor: palette.of(context).background,
                  onTap: (value) => setState(() => tabValue = value)
              )
            )
        ),
        body: tabs[tabValue]
    );
  }

  _getAccount() async {
    try {
      await _getPreferences();
      await _initUser();
      await _initAccount();
    } catch(e) {
      return false;
    }
    return true;
  }

  _initUser() async {
    user = UserManager(uid);
    await user.init();
  }

  _initAccount() async {
    if(platform == "Email") {
      account = AccountManager();
    } else {
      account = SimpleAccountManager();
    }
    account.setUid(uid);
    await account.get();
  }

  _getPreferences() async {
    try {
      final pref = await SharedPreferences.getInstance();
      uid = pref.getString('uid')!;
      platform = pref.getString("platform")!;
    } catch (e) {
      throw Exception;
    }
  }

  _deletePreferences() async {
    final pref = await SharedPreferences.getInstance();
    pref.remove("initial-run");
    pref.remove("uid");
    pref.remove("platform");
  }
}
