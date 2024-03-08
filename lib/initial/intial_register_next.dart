import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:money_won/factory/salary_factory.dart';
import 'package:money_won/factory/user_factory.dart';
import 'package:money_won/fn/date_manager.dart';
import 'package:money_won/fn/dialog_manager.dart';
import 'package:money_won/fn/user_manager.dart';
import 'package:money_won/src/color_palette.dart';
import 'package:money_won/src/system_value.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../fn/money_manager.dart';
import '../tab/tab_main.dart';

class InitialRegisterNextPage extends StatefulWidget {
  final dynamic account;
  final String platform;
  const InitialRegisterNextPage({required this.account, required this.platform, super.key});

  @override
  State<StatefulWidget> createState() {
    return _InitialRegisterNextPage();
  }
}

class _InitialRegisterNextPage extends State<InitialRegisterNextPage> {
  late final dynamic account;

  final dialog = DialogManager();
  final value = SystemValue();
  final palette = ColorPalette();
  final date = DateManager();

  var payday = 0;
  var isLoading = false;
  var isPaydayFilled = false;

  var balanceController = TextEditingController();
  var salaryController = TextEditingController();
  var paydayController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: palette.background,
        appBar: CupertinoNavigationBar(
          middle: Text("회원가입", style: TextStyle(color: palette.textColor)),
          backgroundColor: palette.background
        ),
        body: Container(
          padding: EdgeInsets.all(value.padding2),
          child: Stack(
              children: [
                _buildFormContainer(),
                _buildIndicator()
              ]
          )
        )
    );
  }

  @override
  void initState() {
    super.initState();
    dialog.setContext(context);
    account = widget.account;
    date.initDate();
  }

  _activate() {
    return isPaydayFilled && balanceController.text.isNotEmpty;
  }

  _buildIndicator() {
    return Visibility(
        visible: isLoading,
        child: Center(
            child: SpinKitFadingCube(color: palette.indicatorColor)
        )
    );
  }

  _formInputDecoration(hint, suffix) {
    return InputDecoration(
        isDense: true,
        counterText: "",
        hintText: hint,

        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
            borderSide: BorderSide(width: 1.5, color: palette.systemBlue)
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
            borderSide: BorderSide(width: 1.5, color: palette.secondary)
        ),
        suffixText: suffix,
        suffixStyle: TextStyle(
            color: palette.textColor,
            fontSize: value.caption1
        ),
        hintStyle: TextStyle(
            color: palette.secondary,
            fontSize: value.caption1
        )
    );
  }

  _formAlertContainer(text) {
    return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(value.margin3),
        child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: palette.textAlert,
                fontSize: value.caption1
            )
        )
    );
  }

  _formAccentContainer(text) {
    return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(value.margin3),
        child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: palette.textAccent,
                fontSize: value.caption2
            )
        )
    );
  }

  _buildBalanceContainer() {
    var subText = "";
    final money = MoneyManager();
    if(balanceController.text.isNotEmpty) {
      subText = money.numberToKorean(int.parse(balanceController.text));
    }
    var items = <Widget> [
      TextFormField(
        style: TextStyle(
            color: palette.textColor,
            fontSize: value.body
        ),
        controller: balanceController,
        keyboardType: TextInputType.number,
        decoration: _formInputDecoration("잔액", "원"),
        maxLength: 10,
        onChanged: (text) {
            setState(() {
              if(text.isNotEmpty) {
                int balance = int.parse(text);
                if(balance <= money.maxBalanceLimit) {
                  subText = money.numberToKorean(balance);
                }
              }
            });
        }
      ),
      _formAccentContainer(subText)
    ];

    return Container(
      padding: EdgeInsets.all(value.padding2),
      child: Wrap(children: items)
    );
  }

  _buildPaydayContainer() {
    var items = <Widget>[
      TextFormField(
          style: TextStyle(
              color: palette.textColor,
              fontSize: value.body
          ),
          controller: paydayController,
          keyboardType: TextInputType.number,
          maxLength: 2,
          decoration: _formInputDecoration("월급날", "일"),
          onChanged: (text) => setState(() {
            payday = 0;
            isPaydayFilled = false;
            if(text.isNotEmpty) {
              final date = int.parse(text);
              if(date <= value.maxPaydayValue) {
                payday = date;
                isPaydayFilled = true;
              }
            }
          }),
      ),
      _formAlertContainer("1-28 사이 숫자만 입력하세요")
    ];

    return Container(
        margin: EdgeInsets.all(value.margin2),
        child: Wrap(children: items)
    );
  }

  _buildSalaryContainer() {
    var subText = "";
    final money = MoneyManager();
    if(salaryController.text.isNotEmpty) {
      subText = money.numberToKorean(int.parse(salaryController.text));
    }
    var items = <Widget>[
      TextFormField(
        style: TextStyle(color: palette.textColor),
        controller: salaryController,
        keyboardType: TextInputType.number,
        decoration: _formInputDecoration("월 수령액 (선택)", "원"),
        onChanged: (text) {
          setState(() {
            if(text.isNotEmpty) {
              int balance = int.parse(text);
              if(balance <= money.maxBalanceLimit) {
                subText = money.numberToKorean(balance);
              }
            }
          });
        },
      ),
      _formAccentContainer(subText),
    ];

    return Container(
        margin: EdgeInsets.all(value.margin2),
        child: Wrap(children: items)
    );
  }

  _buildFormContainer() {
    var formItems = <Widget>[
      _buildBalanceContainer(),
      _buildPaydayContainer(),
      _buildSalaryContainer(),
      _buildButtonContainer()
    ];
    return Wrap(children: formItems);
  }

  _buildButtonContainer() {
    return Container(
        margin: EdgeInsets.all(value.margin2),
        child: Material(
            borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
            color: _activate()?palette.buttonBgColor: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
                splashColor: _activate()?palette.buttonFgColor:Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                highlightColor: (_activate())?null:Colors.transparent,
                child: _buildButtonInnerContainer(),
                onTap: () => _finishButtonClickListener()
            )
        )
    );
  }

  _buildButtonInnerContainer() {
    return Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: value.buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
          border: Border.all(
              color: _activate()?Colors.transparent: palette.secondary,
              width: 1
          ),
        ),
        child: Text("완료",
          style: TextStyle(color: _activate()?palette.buttonTextColor:palette.secondary)
        )
    );
  }

  _finishButtonClickListener() {
      if(_activate() && !isLoading) {
        setState(() => dialog.createAlertDialog(
            "가입 절차를 마무리합니다", [
              dialog.dismissButton(),
              CupertinoButton(
                  child: const Text("확인"),
                  onPressed: () => _confirmButtonClickListener()
              )
            ])
        );
    }
  }

  _confirmButtonClickListener() {
    setState(() {
      isLoading = true;
      final money = MoneyManager();
      final balance = money.koreanToNumber(balanceController.text) ?? 0;
      final salary = Salary(salary: {});
      if(salaryController.text.isNotEmpty) {
        final value = money.koreanToNumber(salaryController.text);
        salary.set(date.getCalendar(), value);
      }
      Navigator.of(context).pop();
      _createAccount(balance: balance, payday: payday, salary: salary).then((value) {
        _buildNavigator();
        isLoading = false;
      });
    });
  }

  _buildNavigator() {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, anim, secondary) => const TabMain(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
              position: animation.drive(
                  Tween(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero
                  ).chain(CurveTween(curve: Curves.ease))),
              child: child,
            )
        )
    );
  }

  _createAccount({required balance, required payday, required salary}) async {
    try {
      final userName = await account.getUserName();
      await account.create();
      var user = UserManager(account.getUid());
      await user.create(
          User(
              name: userName,
              colors: [],
          )
      );
      await _setPreferences();
    } catch(e) {
      dialog.createAlertDialog("문제가 발생했습니다", [dialog.confirmButton()]);
    }
  }

  _setPreferences() async {
    final pref = await SharedPreferences.getInstance();
    pref.setBool("initial-run", false);
    pref.setString("uid", account.uid);
    pref.setString("platform", widget.platform);
  }
}