import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '/fn/account_manager.dart';
import '/fn/dialog_manager.dart';
import '/src/color_palette.dart';
import '/src/system_value.dart';


class ProfilePasswordEditPage extends StatefulWidget {
  final AccountManager account;
  const ProfilePasswordEditPage({required this.account, super.key});

  @override
  State<StatefulWidget> createState() {

    return _ProfilePasswordEditPage();
  }
}

class _ProfilePasswordEditPage extends State<ProfilePasswordEditPage> {
  late final AccountManager account;
  final value = SystemValue();
  final dialog = DialogManager();
  final palette = ColorPalette();

  final prevPwController = TextEditingController();
  final newPwController = TextEditingController();
  var rePwController = TextEditingController();

  var isWrongPassword = false;
  var isNotMatching = false;
  var isSame = false;
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: palette.of(context).background,
        appBar: CupertinoNavigationBar(backgroundColor: palette.of(context).background),
        body: Container(
          color: palette.of(context).background,
          padding: EdgeInsets.all(value.margin2),
          child: Stack(
              children: [
                Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      _buildPrevPasswordContainer(),
                      _buildNewPasswordContainer(),
                      _buildReNewPasswordContainer()
                    ]
                ),
                _buildButtonContainer(),
                _buildIndicator()
              ]
          ),
        )
    );
  }

  @override
  void initState() {
    super.initState();
    account = widget.account;
    dialog.setContext(context);
  }

  _buildIndicator() {
    return Visibility(
        visible: isLoading,
        child: Center(
            child: SpinKitFadingCube(
              color: palette.of(context).systemBlue,
            )
        )
    );
  }

  _formInputDecoration(hint) {
    return InputDecoration(
        isDense: true,
        counterText: "",
        hintText: hint,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
            borderSide: BorderSide(width: 1.5, color: palette.of(context).systemBlue)
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
            borderSide: BorderSide(width: 1.5, color: palette.of(context).secondary)
        ),
        hintStyle: TextStyle(
            color: palette.of(context).secondary,
            fontSize: value.caption1
        )
    );
  }

  _buildPrevPasswordContainer() {
    return Wrap(
      children: [
        Container(
            margin: EdgeInsets.all(value.margin3),
            child: TextFormField(
                style: TextStyle(color: palette.of(context).textColor),
                maxLength: value.maxPasswordLength,
                keyboardType: TextInputType.text,
                controller: prevPwController,
                obscureText: true,
                decoration: _formInputDecoration("기존 비밀번호")
            )
        ),
        Visibility(
            visible: isWrongPassword,
            child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: value.margin3),
                child: Text("잘못된 비밀번호입니다",
                    style: TextStyle(
                        color: palette.of(context).textAlert,
                        fontSize: value.caption3
                    )
                )
            )
        )
      ]
    );
  }

  _buildNewPasswordContainer() {
    return Wrap(
      children: [
        Container(
            margin: EdgeInsets.all(value.margin3),
            child: TextFormField(
                style: TextStyle(color: palette.of(context).textColor),
                maxLength: value.maxPasswordLength,
                obscureText: true,
                keyboardType: TextInputType.text,
                controller: newPwController,
                decoration: _formInputDecoration("새 비밀번호")
            )
        ),
        Visibility(
            visible: newPwController.text.length < value.minPasswordLength,
            child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: value.margin3),
                child: Text("6자 이상의 영문/숫자를 사용하세요 (20자 이하)",
                    style: TextStyle(
                        color: palette.of(context).textAlert,
                        fontSize: value.caption3
                    )
                )
            )
        )
      ]
    );
  }

  _buildReNewPasswordContainer() {
    return Wrap(
      children: [
        Container(
            margin: EdgeInsets.all(value.margin3),
            child: TextFormField(
                style: TextStyle(color: palette.of(context).textColor),
                obscureText: true,
                maxLength: value.maxPasswordLength,
                keyboardType: TextInputType.text,
                controller: rePwController,
                decoration: _formInputDecoration("새 비밀번호 재입력")
            )
        ),
        Visibility(
            visible: isNotMatching,
            child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: value.margin3),
                child: Text("비밀번호가 일치하지 않습니다",
                    style: TextStyle(
                        color: palette.of(context).textAlert,
                        fontSize: value.caption3
                    )
                )
            )
        )
      ]
    );
  }

  _buildButtonContainer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Visibility(
            visible: isSame,
            child: Container(
                margin: EdgeInsets.only(bottom: value.margin3),
                child: Text("기존 비밀번호와 일치합니다",
                    style: TextStyle(
                        color: palette.of(context).textAlert,
                        fontSize: value.caption3
                    )
                )
            )
        ),
        Container(
            margin: EdgeInsets.all(value.margin2),
            alignment: Alignment.bottomCenter,
            child: Material(
                color: palette.of(context).systemBlue,
                borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
                child: InkWell(
                    splashFactory: NoSplash.splashFactory,
                    borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
                    onTap: () => setState(() {
                      isLoading = true;
                      if(newPwController.text.length >= value.minPasswordLength) {
                        if (_checkRePw() && _checkPrevPw() && _checkNewPw()) {
                          account.setPassword(newPwController.text)
                              .then((value) => Navigator.of(context).pop());
                        }
                      }
                      isLoading = false;
                    }),
                    child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: value.buttonHeight,
                        child: Text("변경",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: value.body,
                                color: palette.of(context).systemWhite
                            )
                        )
                    )
                )
            )
        )
      ],
    );
  }

  _checkRePw() {
    if(rePwController.text == newPwController.text) {
      isNotMatching = false;
      return true;
    } else {
      isNotMatching = true;
      return false;
    }
  }

  _checkNewPw() {
    if(prevPwController.text == newPwController.text) {
      isSame = true;
      return false;
    } else {
      isSame = false;
      return true;
    }
  }

  _checkPrevPw() => !account.checkPassword(prevPwController.text);
}


