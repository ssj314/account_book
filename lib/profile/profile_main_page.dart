import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/enum/MoneyController.dart';
import '/fn/account_bank_manager.dart';
import '/fn/account_manager.dart';
import '/fn/date_manager.dart';
import '/fn/dialog_manager.dart';
import '/fn/input_manager.dart';
import '/fn/money_manager.dart';
import '/fn/user_manager.dart';
import '/initial/initial_main.dart';
import '/profile/profile_edit_name_page.dart';
import '/profile/profile_edit_password_page.dart';
import '/src/color_palette.dart';
import '/src/system_value.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfilePage extends StatefulWidget {
  final UserManager user;
  final AccountManager account;
  const ProfilePage({required this.user, required this.account, super.key});

  @override
  createState() {
    return _ProfilePage();
  }
}

class _ProfilePage extends State<ProfilePage> {
  late final UserManager user;
  late final AccountManager account;
  late final BankManager bank;
  final value = SystemValue();
  final dialog = DialogManager();
  final palette = ColorPalette();
  final date = DateManager();
  final money = MoneyManager();

  @override
  build(BuildContext context) {
    return  Container(
      color: palette.of(context).primary,
        child:Scaffold(
            backgroundColor: palette.of(context).primary,
            appBar: CupertinoNavigationBar(
                backgroundColor: palette.of(context).background,
                middle: Text("설정",
                  style: TextStyle(
                      fontSize: value.body,
                      color: palette.of(context).textColor
                  ),
                )
            ),
            body: ListView(
                children: [
                  _buildProfileContainer(),
                  Container(
                    height: value.margin3,
                    color: palette.of(context).background,
                  ),
                  _buildAccountContainer(),
                  Container(
                    height: value.margin3,
                    color: palette.of(context).background,
                  ),
                  _buildDataContainer(),
                  Container(
                    height: value.margin3,
                    color: palette.of(context).background,
                  ),
                  _buildLogOutButton(),
                  _buildWithdrawalButton(),
                  Container(
                    height: value.margin3,
                    color: palette.of(context).background,
                  )
                ]
            )
        )
    );
  }

  @override
  initState() {
    super.initState();
    user = widget.user;
    date.initDate();
    bank = user.getBank();
    account = widget.account;
    dialog.setContext(context);
  }

  _buildProfileContainer() {
    return Container(
        padding: EdgeInsets.all(value.padding3),
        margin: EdgeInsets.only(
          top: value.margin3,
          bottom: value.margin3,
          right: value.margin2,
          left: value.margin2,
        ),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                  Icons.account_circle,
                  color: palette.of(context).secondary,
                  size: value.iconRegular2
              ),
              Container(width: value.margin2),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(user.getName(),
                        style: TextStyle(
                            height: 1.5,
                            color: palette.of(context).textColor,
                            fontSize: value.body,
                            fontWeight: FontWeight.bold
                        )
                    )
                  ]
              )
            ]
        )
    );
  }

  _buildAccountContainer() {
    return Container(
        padding: EdgeInsets.all(value.padding3),
        margin: EdgeInsets.only(
            left: value.margin2,
            right: value.margin2
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.all(value.padding3),
                child: Text("계정",
                  style: TextStyle(
                      color: palette.of(context).textColor,
                      fontSize: value.title2,
                      fontWeight: FontWeight.bold
                  ),
                )
            ),
            _buildEditNameButton(),
            _buildEditPasswordButton()
          ]
      )
    );
  }

  _buildEditNameButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
          splashFactory: NoSplash.splashFactory,
          borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
          child: Container(
              margin: EdgeInsets.all(value.margin4),
              padding: EdgeInsets.all(value.padding3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.badge_rounded,
                      size: value.iconSmall2,
                      color: palette.of(context).systemBlue,
                    ),
                    Container(
                      alignment: Alignment.center,
                        margin: EdgeInsets.only(left: value.margin2),
                        child: Text("이름 변경",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                height: 1.0,
                                color: palette.of(context).textColor,
                                fontSize: value.body
                            )
                        )
                    )
                  ]
              )
          ),
          onTap: () => _buildNavigator(ProfileNameEditPage(user: user, account: account)).then((value) => setState(() {}))
      )
    );
  }

  _buildEditPasswordButton() {
    return Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
          child: Container(
              margin: EdgeInsets.all(value.margin4),
              padding: EdgeInsets.all(value.padding3),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock,
                      size: value.iconSmall2,
                      color: palette.of(context).systemBlue,
                    ),
                    Container(
                        margin: EdgeInsets.only(left: value.margin2),
                        child: Text("비밀번호 변경",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: palette.of(context).textColor,
                                fontSize: value.body,
                                height: 1.0
                            )
                        )
                    )
                  ]
              )
          ),
          onTap: () {
            try {
              _buildNavigator(ProfilePasswordEditPage(account: account)).then((value) => setState(() {}));
            } catch(e) {
              dialog.createAlertDialog("비밀번호를 변경할 수 없습니다", [dialog.confirmButton()]);
            }
          }
      )
    );
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

  _buildDataContainer() {
    return Container(
        padding: EdgeInsets.all(value.padding3),
        margin: EdgeInsets.only(
            left: value.margin2,
            right: value.margin2
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: EdgeInsets.all(value.padding3),
                  child: Text("자산 정보",
                    style: TextStyle(
                        color: palette.of(context).textColor,
                        fontSize: value.title2,
                        fontWeight: FontWeight.bold
                    ),
                  )
              ),
              _buildSalaryButton(),
              _buildPaydayButton(),
              //_buildPaySyncButton()
            ]
        ));
  }

  _buildSalaryButton() {
    return Material(
        color: Colors.transparent,
        child: InkWell(
            splashFactory: NoSplash.splashFactory,
            borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
            child: Container(
                margin: EdgeInsets.all(value.margin4),
                padding: EdgeInsets.all(value.padding3),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.paid_rounded,
                        size: value.iconSmall2,
                        color: palette.of(context).systemBlue,
                      ),
                      Container(
                          margin: EdgeInsets.only(left: value.margin2),
                          child: Text("급여 설정",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: palette.of(context).textColor,
                                  fontSize: value.body
                              )
                          )
                      )
                    ]
                )
            ),
            onTap: () => showCupertinoModalPopup(
                context: context,
                builder: (context) => _buildSalaryInputContainer()
            )
        )
    );
  }

  _buildSalaryInputContainer() {
    var controller = MoneyController();
    return InputManager(
        title: "급여 설정하기",
        body: "변경할 내역",
        controller: controller,
        buttons: [
          CupertinoButton(
              child: Text("확인",
                  style: TextStyle(
                      color: palette.of(context).textAccent,
                      fontSize: value.body
                  )
              ),
              onPressed: () => setState(() {
                if(controller.text.isNotEmpty) {
                  bank.setSalary(
                      date.getCalendar(date: 0),
                      money.koreanToNumber(controller.text)
                  );
                  Navigator.of(context).pop();
                }
              })
          )
        ]
    );
  }

  _buildPaydayButton() {
    return Material(
        color: Colors.transparent,
        child: InkWell(
            splashFactory: NoSplash.splashFactory,
            borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
            child: Container(
                margin: EdgeInsets.all(value.margin4),
                padding: EdgeInsets.all(value.padding3),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: value.iconSmall2,
                        color: palette.of(context).systemBlue,
                      ),
                      Container(
                          margin: EdgeInsets.only(left: value.margin2),
                          child: Text("월급날 변경",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: palette.of(context).textColor,
                                  fontSize: value.body
                              )
                          )
                      )
                    ]
                )
            ),
            onTap: () => showCupertinoModalPopup(
                context: context,
                builder: (context) => _buildPaydaySelector()
            )
        )
    );
  }

  _buildPaydaySelector() {
    var payday = 0;
    return Material(
        color: Colors.transparent,
        child: Container(
            height: value.modalHeightLarge,
            margin: EdgeInsets.all(value.margin2),
            padding: EdgeInsets.all(value.padding2),
            decoration: BoxDecoration(
                color: palette.of(context).background,
                borderRadius: BorderRadius.all(Radius.circular(value.radiusModal))
            ),
            child: Wrap(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            margin: EdgeInsets.all(value.margin3),
                            child: Text(
                                "날짜 선택하기",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: value.body,
                                    color: palette.of(context).textColor
                                )
                            )
                        ),
                        Center(
                            child: InkWell(
                                child: Icon(Icons.close_rounded,
                                    color: palette.of(context).secondary,
                                    size: value.iconSmall1
                                ),
                                onTap: () => Navigator.of(context).pop()
                            )
                        )
                      ]
                  ),
                  Container(
                      height: value.modalHeightSmall,
                      padding: EdgeInsets.only(left: value.margin3),
                      child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(initialItem: bank.getPayday() - 1),
                          itemExtent: 42,
                          onSelectedItemChanged: (int value) => setState(() => payday = value),
                          children: List.generate(28, (index) =>
                              Center(
                                  child: Text('${index+1}일',
                                      style: TextStyle(color: palette.of(context).textColor)
                                  )
                              )
                          )
                      )
                  ),
                  Center(
                      child: CupertinoButton(
                          child: Text("확인",
                              style: TextStyle(
                                  color: palette.of(context).textAccent,
                                  fontSize: value.body
                              )),
                          onPressed: () => setState(() {
                            bank.setPayday(payday + 1);
                            Navigator.of(context).pop();
                          })
                      )
                  )
                ]
            )
        )
    );
  }

  _buildPaySyncButton() {
    return Material(
        color: Colors.transparent,
        child: InkWell(
            splashFactory: NoSplash.splashFactory,
            borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
            child: Container(
                padding: EdgeInsets.all(value.padding2),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.credit_score,
                        size: value.iconSmall2,
                        color: palette.of(context).systemBlue,
                      ),
                      Container(
                          margin: EdgeInsets.only(left: value.margin2),
                          child: Text("월급 입금",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: palette.of(context).textColor,
                                  fontSize: value.body,
                                  height: 1.0
                              )
                          )
                      )
                    ]
                )
            ),
            onTap: () {
              final salary = bank.getSalary(date.getCalendar(date: 0));
              if(bank.getPayday() == date.getCurrentDate()) {
                dialog.createAlertDialog("${money.numberToKorean(salary)}을 입급하겠습니까?", [
                  dialog.dismissButton(),
                  CupertinoButton(
                      child: const Text("확인"),
                      onPressed: () {
                        setState(() {
                          bank.addBalance(salary);
                          Navigator.of(context).pop();
                        });
                      }
                  )
                ]);
              }
            }
        )

    );
  }

  _buildLogOutButton() {
    return Container(
        margin: EdgeInsets.only(
            left: value.margin2,
            right: value.margin2
        ),
      child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.all(value.padding2),
              child: Text("로그아웃",
                  style: TextStyle(color: palette.of(context).textColor, fontSize: value.caption1)
              )
          ),
          onTap: () => setState(() =>
              dialog.createAlertDialog("정말 로그아웃하시겠습니까?", [
                dialog.dismissButton(),
                CupertinoButton(
                    child: Text("확인", style: TextStyle(color: palette.of(context).textAccent)),
                    onPressed: () => _logOut().then((value) => _buildNavigator(InitialMainPage()))
                )
              ])
          )
      )
    );
  }

  _buildWithdrawalButton() {
    return Container(
        margin: EdgeInsets.only(
            left: value.margin2,
            right: value.margin2
        ),
        child:InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.all(value.padding2),
                child: Text("회원탈퇴",
                    style: TextStyle(color: palette.of(context).textAlert, fontSize: value.caption1)
                )
            ),
            onTap: () => setState(() {
              dialog.createAlertDialog("정말 계정을 삭제하겠습니까?", [
                dialog.dismissButton(),
                CupertinoButton(
                    child: Text("확인", style: TextStyle(color: palette.of(context).textAccent)),
                    onPressed: () {
                      _removeUserData();
                      _logOut().then((value) => _buildNavigator(InitialMainPage()));
                    })
              ]);
            })
        )
    );
  }

  _logOut() async {
    await account.signOut();
    final pref = await SharedPreferences.getInstance();
    pref.remove("initial-run");
    pref.remove("uid");
  }

  _removeUserData() async {
    await account.delete();
    await user.delete();
  }
}


