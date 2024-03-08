import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:money_won/fn/account_bank_manager.dart';
import 'package:money_won/fn/date_manager.dart';
import 'package:money_won/fn/dialog_manager.dart';
import 'package:money_won/fn/user_manager.dart';
import 'package:money_won/menu/menu_bank_name_page.dart';
import 'package:money_won/menu/menu_daily_page.dart';
import 'package:money_won/menu/menu_yearly_page.dart';
import 'package:money_won/profile/profile_main_page.dart';
import 'package:money_won/src/color_palette.dart';
import 'package:money_won/src/system_value.dart';

import '../menu/menu_monthly_page.dart';

class MenuPage extends StatefulWidget {
  final UserManager user;
  final dynamic account;
  const MenuPage({required this.user, required this.account, super.key});

  @override
  State<StatefulWidget> createState() {
    return _MenuPage();
  }
}

class _MenuPage extends State<MenuPage> {
  late final UserManager user;
  late final BankManager bank;
  late final dynamic account;

  final value = SystemValue();
  final palette = ColorPalette();
  final date = DateManager();
  final dialog = DialogManager();

  var isLoading = false;
  var bankList = [];
  int bankIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            color: palette.of(context).background,
            padding: EdgeInsets.only(
              right: value.padding2,
              left: value.padding2,
            ),
            child: ListView(
                primary: false,
                children: [
                  Container(
                      padding: EdgeInsets.only(top: value.padding1),
                      margin: EdgeInsets.all(value.margin2),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("메뉴",
                                style: TextStyle(
                                    color: palette.of(context).textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: value.title1
                                )

                            ),
                            InkWell(
                                child: Icon(Icons.settings,
                                  size: value.iconSmall2,
                                  color: palette.of(context).accent,
                                ),
                                onTap: () {
                                  _buildNavigator(ProfilePage(user: user, account: account));
                                }
                            )
                          ]
                      )
                  ),
                  Container(
                      decoration: BoxDecoration(
                          color: palette.of(context).primary,
                          borderRadius: BorderRadius.all(Radius.circular(value.radius1))
                      ),
                      padding: EdgeInsets.all(value.padding2),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.all(value.margin3),
                              alignment: Alignment.center,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                        "소비 분석",
                                        style: TextStyle(
                                            color: palette.of(context).textColor,
                                            fontSize: value.title3,
                                            fontWeight: FontWeight.bold,
                                            height: 1.0
                                        )
                                    ),
                                    Text("현재 가계부 - ${bankList[bankIndex ?? 0]}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: palette.of(context).systemGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: value.caption2,
                                            height: 1.0
                                        )

                                    )
                                  ]
                              ),
                            ),
                            _buildAnalysisContainer(),
                          ])
                  ),
                  Container(height: value.padding2),
                  Container(
                      decoration: BoxDecoration(
                          color: palette.of(context).primary,
                          borderRadius: BorderRadius.all(Radius.circular(value.radius1))
                      ),
                      padding: EdgeInsets.all(value.padding2),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                margin: EdgeInsets.all(value.margin3),
                                child: Text(
                                    "가계부 관리",
                                    style: TextStyle(
                                        color: palette.of(context).textColor,
                                        fontSize: value.title3,
                                        fontWeight: FontWeight.bold
                                    )
                                )
                            ),
                            _buildManageContainer()
                          ]
                      )
                  )
                ]
            )
        ),
        Visibility(
            visible: isLoading,
            child: SpinKitFadingCube(color: palette.of(context).systemBlue)
        )
      ]
    );
  }


  @override
  void initState() {
    super.initState();
    date.initDate();
    user = widget.user;
    account = widget.account;
    bank = user.getBank();
    dialog.setContext(context);
    bankList = bank.getList();
    bankIndex = bank.getIndex();
  }

  _buildNavigator(page) {
    return Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, anim, secondary) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
                position: animation.drive(
                    Tween(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero
                    ).chain(CurveTween(curve: Curves.ease))
                ),
                child: child
            )
    )
    );
  }

  _buildManageContainer() {
    return Container(
        margin: EdgeInsets.all(value.margin3),
        child: Material(
            color: palette.of(context).primary,
            child: Wrap(
                children: [
                  _buildAddAccountButton(),
                  _buildEditAccountButton(),
                  _buildDeleteAccountButton()
                ]
            )
        )
    );
  }

  _buildAddAccountButton() {
    return InkWell(
        splashFactory: NoSplash.splashFactory,
        borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
        child: Container(
            padding: EdgeInsets.all(value.padding3),
            child: Row(
                children: [
                  Icon(
                      Icons.add,
                      color: palette.of(context).systemBlue,
                      size: value.iconSmall1
                  ),
                  Container(width: value.margin2),
                  Text("가계부 추가하기",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: palette.of(context).textColor,
                        fontSize: value.body
                    ),
                  )
                ]
            )
        ),
        onTap: () => setState(() {
          if(bankList.length < 4) {
            isLoading = true;
            _buildNavigator(BankNameEditPage(user: user)).then((value) {
              if(value == null) {
                dialog.createAlertDialog("취소되었습니다", [
                  dialog.confirmButton()
                ]);
              } else {
                bankList = bank.getList();
                dialog.createAlertDialog("새 가계부가 생성되었습니다", [
                  dialog.confirmButton()
                ]);
              }
            });
            isLoading = false;
          } else {
            dialog.createAlertDialog("더 이상 추가할 수 없습니다", [
              dialog.confirmButton()
            ]);
          }
        })
    );
  }
  
  _buildEditAccountButton() {
    bankList = bank.getList();
    return InkWell(
        splashFactory: NoSplash.splashFactory,
        borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
        child: Container(
            padding: EdgeInsets.all(value.padding3),
            child: Row(
                children: [
                  Icon(
                      Icons.drive_file_rename_outline_rounded,
                      color: palette.of(context).systemBlue,
                      size: value.iconSmall1
                  ),
                  Container(width: value.margin2),
                  Text("가계부 이름 변경하기",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: palette.of(context).textColor,
                        fontSize: value.body
                    ),
                  )
                ]
            )
        ),
        onTap: () => showCupertinoModalPopup(
            context: context,
            builder: (context) => Container(
                margin: EdgeInsets.only(bottom: value.margin2),
                child: CupertinoActionSheet(
                    actions: List.generate(bankList.length, (index) {
                      return CupertinoButton(
                          minSize: value.buttonHeight,
                          child: Text(
                              "${bankList[index]}",
                              style: TextStyle(color: palette.of(context).textAccent)
                          ),
                          onPressed: () => setState(() {
                            isLoading = true;
                            final previous = bankList[index];
                            Navigator.of(context).pop();
                            _buildNavigator(BankNameEditPage(user: user, mode: false, index: index)).then((value) {
                              String stateMsg = (value == null)?"취소되었습니다":"성공적으로 변경되었습니다";
                              dialog.createAlertDialog(stateMsg, [dialog.confirmButton()]);
                              bankList = bank.getList();
                            });
                            isLoading = false;
                          })
                      );
                    }),
                    cancelButton: dialog.dismissButton()
                )
            )
        )
    );
  }

  _buildDeleteAccountButton() {
    bankList = bank.getList();
    return InkWell(
        splashFactory: NoSplash.splashFactory,
        borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
        child: Container(
            padding: EdgeInsets.all(value.padding3),
            child: Row(
                children: [
                  Icon(
                      Icons.delete_forever_rounded,
                      color: palette.of(context).systemBlue,
                      size: value.iconSmall1
                  ),
                  Container(width: value.margin2),
                  Text("가계부 삭제하기",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: palette.of(context).textColor,
                        fontSize: value.body
                    ),
                  )
                ]
            )
        ),
        onTap: () {
          if(bankList.length > 1) {
            showCupertinoModalPopup(
                context: context,
                builder: (context) => Container(
                    margin: EdgeInsets.only(bottom: value.margin2),
                    child: CupertinoActionSheet(
                        actions: List.generate(bankList.length, (index) {
                          return CupertinoButton(
                              minSize: value.buttonHeight,
                              child: Text(
                                  "${bankList[index]}",
                                  style: TextStyle(color: palette.of(context).textAccent)
                              ),
                              onPressed: () => setState(() {
                                isLoading = true;
                                Navigator.of(context).pop();
                                final deletedBank = bankList[index];
                                bank.delete(index);
                                bankIndex = 0;
                                bankList = bank.getList();
                                dialog.createAlertDialog("$deletedBank(이)가 삭제되었습니다", [dialog.confirmButton()]);
                                isLoading = false;
                              })
                          );
                        }),
                        cancelButton: dialog.dismissButton()
                    )
                )
            );
          } else {
            dialog.createAlertDialog("더 이상 삭제할 수 없습니다", [dialog.confirmButton()]);
          }
        }
    );
  }

  _buildAnalysisContainer() {
    return Container(
        margin: EdgeInsets.all(value.margin3),
        child: Material(
            color: palette.of(context).primary,
            child: Wrap(
                children: [
                  _buildDailyAnalysisButton(),
                  _buildMonthlyAnalysisButton(),
                  _buildYearlyAnalysisButton(),
                ]
            )
        )
    );
  }

  _buildMonthlyAnalysisButton() {
    return InkWell(
        splashFactory: NoSplash.splashFactory,
        borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
        child: Container(
            padding: EdgeInsets.all(value.padding3),
            child: Row(
                children: [
                  Icon(
                      Icons.pie_chart_rounded,
                      color: palette.of(context).systemBlue,
                      size: value.iconSmall1
                  ),
                  Container(width: value.margin2),
                  Text("월간 소비 분석",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: palette.of(context).textColor,
                        fontSize: value.body
                    ),
                  )
                ]
            )
        ),
        onTap: () => _buildNavigator(MonthlyAnalysisPage(user: user, account: account, date: date.copy()))
    );
  }

  _buildYearlyAnalysisButton() {
    return InkWell(
        splashFactory: NoSplash.splashFactory,
        borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
        child: Container(
            padding: EdgeInsets.all(value.padding3),
            child: Row(
                children: [
                  Icon(
                      Icons.bar_chart_rounded,
                      color: palette.of(context).systemBlue,
                      size: value.iconSmall1
                  ),
                  Container(width: value.margin2),
                  Text("연간 소비 분석",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: palette.of(context).textColor,
                        fontSize: value.body
                    ),
                  )
                ]
            )
        ),
        onTap: () => _buildNavigator(YearlyAnalysisPage(user: user, account: account, date: date.copy()))
    );
  }

  _buildDailyAnalysisButton() {
    return InkWell(
        splashFactory: NoSplash.splashFactory,
        borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
        child: Container(
            padding: EdgeInsets.all(value.padding3),
            child: Row(
                children: [
                  Icon(
                      Icons.donut_large_rounded,
                      color: palette.of(context).systemBlue,
                      size: value.iconSmall1
                  ),
                  Container(width: value.margin2),
                  Text("일일 소비 분석",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: palette.of(context).textColor,
                        fontSize: value.body
                    ),
                  )
                ]
            )
        ),
        onTap: () => _buildNavigator(DailyAnalysisPage(user: user, account: account, date: date.copy()))
    );
  }
}
