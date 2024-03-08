import 'package:flutter/cupertino.dart';
import 'package:money_won/enum/MoneyController.dart';
import 'package:money_won/fn/account_bank_manager.dart';
import 'package:money_won/fn/date_manager.dart';
import 'package:money_won/fn/input_manager.dart';
import 'package:money_won/fn/money_manager.dart';
import 'package:money_won/src/color_palette.dart';
import 'package:money_won/src/system_value.dart';
import '../fn/user_manager.dart';
import '/fn/dialog_manager.dart';
import 'package:flutter/material.dart';

class HomeInnerPage extends StatefulWidget {
  final UserManager user;
  final DateManager date;
  const HomeInnerPage({required this.user, required this.date, super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeInnerPage();
  }
}

class _HomeInnerPage extends State<HomeInnerPage> {
  late final UserManager user;
  late final DateManager date;
  late final BankManager bank;

  final value = SystemValue();
  final palette = ColorPalette();
  final dialog = DialogManager();
  final money = MoneyManager();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
            color: palette.of(context).primary
        ),
        padding: EdgeInsets.all(value.padding2),
        margin: EdgeInsets.all(value.margin3),
        child: _buildAccountContainer()
    );
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
    date = widget.date;
    bank = user.getBank();
    dialog.setContext(context);
  }

  // 요약
  _buildAccountContainer() {
    final items = <Widget>[
      Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.all(value.margin3),
          child: Text("전체",
              style: TextStyle(
                color: palette.of(context).textColor,
                fontSize: value.title2,
                fontWeight: FontWeight.bold
              )
          )
      ),
      _buildBalanceContainer(),
      _buildIncomeContainer()
    ];
    return Column(children: items);
  }

  _buildIncomeContainer() {
    final calendar = date.getCalendar(date: 0);
    final salary = bank.getSalary(calendar);
    final text = (salary == 0)?"미지정":"${money.currency.format(salary)}원";
    return Container(
        padding: EdgeInsets.all(value.margin3),
        child: Row(
            children: [
              Image.asset("image/monthly_salary.png",
                  color: palette.of(context).systemBlue,
                  width: value.iconRegular3
              ),
              Container(
                  padding: EdgeInsets.only(left: value.padding1),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(date.isCurrentMonth()?"이번 달 급여":"${date.getMonth()}월 급여",
                            style: TextStyle(
                                color: palette.of(context).textColor,
                                fontSize: value.caption2
                            )
                        ),
                        Text(text,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: palette.of(context).textColor,
                              fontSize: value.title3
                          )
                        )
                      ]
                  )
              )
            ]
        )
    );
  }

  _buildBalanceContainer() {
    final balance = bank.getBalance();
    return Container(
        padding: EdgeInsets.all(value.margin3),
        child: InkWell(
            child: Row(
                children: [
                  Image.asset(
                    "image/account_balance.png",
                    color: palette.of(context).systemBlue,
                    width: value.iconRegular3,
                  ),
                  Container(
                      padding: EdgeInsets.only(left: value.padding1),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("자산",
                              style: TextStyle(
                                  color: palette.of(context).textColor,
                                  fontSize: value.caption1
                              )
                            ),
                            Text("${money.currency.format(balance)}원",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: palette.of(context).textColor,
                                  fontSize: value.title3
                              )
                            )
                          ]
                      )
                  )
                ]
            ),
            onTap: () => showCupertinoModalPopup(
                context: context,
                builder: (context) => _buildBalanceEditContainer(context, balance)
            )
        )
    );
  }

  _buildBalanceEditContainer(context, balance) {
    final controller = MoneyController();
    return InputManager(
        title: "자산 관리하기",
        body: "입·출금 액수",
        controller: controller,
        buttons: [
          Container(
              alignment: Alignment.center,
              child: CupertinoButton(
                  child: Text("출금",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          height: 1,
                          color: palette.of(context).textAlert,
                          fontSize: value.body
                      )),
                  onPressed: () {
                    setState(() {
                      Navigator.of(context).pop();
                      if(controller.text.isNotEmpty) {
                        final value = money.koreanToNumber(controller.text);
                        if(balance >= value) {
                          bank.addBalance(-value);
                        } else {
                          dialog.createAlertDialog("잔액이 부족합니다", [dialog.confirmButton()]);
                        }
                      }
                    });
                  }
              )
          ),
          Container(
              alignment: Alignment.center,
              child: CupertinoButton(
                  child: Text("초기화",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          height: 1,
                          color: palette.of(context).textColor,
                          fontSize: value.caption2
                      )),
                  onPressed: () =>
                      dialog.createAlertDialog(
                          "정말 초기화하겠습니까?", [
                        dialog.dismissButton(),
                        CupertinoButton(
                            child: Text("확인",
                                style: TextStyle(color: palette.of(context).textAccent)
                            ),
                            onPressed: () =>
                                setState(() {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  bank.addBalance(-balance);
                                }
                                )
                        )
                      ])
              )
          ),
          Container(
              alignment: Alignment.center,
              child: CupertinoButton(
                  child: Text("입금",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          height: 1,
                          color: palette.of(context).textAccent,
                          fontSize: value.body
                      )),
                  onPressed: () {
                    setState(() {
                      if(controller.text.isNotEmpty) {
                        final value = money.koreanToNumber(controller.text);
                        if(balance + value > money.maxBalanceLimit) {
                          dialog.createAlertDialog(
                              "100억을 초과할 수 없습니다",
                              [dialog.confirmButton()]
                          );
                        } else {
                          bank.addBalance(value);
                          Navigator.of(context).pop();
                        }
                      }
                    });
                  }
              )
          )
        ]
    );
  }
}
