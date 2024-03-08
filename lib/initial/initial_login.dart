import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '/fn/account_manager.dart';
import '/fn/dialog_manager.dart';
import '/fn/user_manager.dart';
import '/src/color_palette.dart';
import '/src/system_value.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as Kakao;
import '/factory/user_factory.dart' as UserFactory;
import '/tab/tab_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fn/simple_account_manager.dart';

class InitialLoginPage extends StatefulWidget {
  const InitialLoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
      return _InitialLoginPage();
  }
}

class _InitialLoginPage extends State<InitialLoginPage> {
  final value = SystemValue();
  final palette = ColorPalette();
  final dialog = DialogManager();
  late final dynamic account;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isEmailFilled = false;
  var isPasswordFilled = false;
  var isUnknownAccount = false;
  var isWrongPassword = false;
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: palette.of(context).background,
        appBar: CupertinoNavigationBar(
            backgroundColor: palette.of(context).background,
            middle: Text(
                "이메일로 로그인하기",
                style: TextStyle(color: palette.of(context).textColor)
            )
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
  }

  _buildIndicator() {
    return Visibility(
        visible: isLoading,
        child: Center(child: SpinKitFadingCube(color: palette.of(context).indicatorColor))
    );
  }

  _buildFormContainer() {
    var formItems = <Widget>[
      _buildEmailTextFormField(),
      _buildPasswordTextFormField(),
    ];

    return Wrap(children: [
      AutofillGroup(child: Column(children: formItems)),
      Container(height: value.margin2),
      _buildButtonContainer(),
      Container(height: value.padding2),
      Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 1,
              margin: EdgeInsets.all(value.padding2),
              color: palette.of(context).textColor,
            ),
            Container(
              padding: EdgeInsets.all(value.padding2),
              color: palette.of(context).background,
              child: Text(
                "간편 로그인",
                textAlign: TextAlign.center,
                style: TextStyle(
                    height: 1,
                    color: palette.of(context).textColor,
                    fontSize: value.caption2
                ),
              ),
            )
          ]
      ),
      _buildGoogleButton(),
      _buildKakaoButton()
    ]);
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

  _formAlertContainer(visible, text) {
    return Visibility(
        visible: visible,
        child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(value.margin3),
            child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: palette.of(context).textAlert,
                    fontSize: value.caption2
                )
            )
        )
    );
  }

  _buildEmailTextFormField() {
    var formItems = <Widget>[
      TextFormField(
          autofillHints: const [AutofillHints.email],
          style: TextStyle(color: palette.of(context).textColor),
          controller: emailController,
          keyboardType: TextInputType.text,
          enableSuggestions: true,
          autocorrect: false,
          decoration: _formInputDecoration("이메일 주소"),
          onChanged: (text) => setState(() {
            if(text.isNotEmpty) {
              if(RegExp(value.emailRegex).hasMatch(text)) {
                isEmailFilled = true;
                return;
              }
            }
            isEmailFilled = false;
          })
      ),
      _formAlertContainer(isUnknownAccount, "존재하지 않는 계정입니다"),

    ];
    return Container(
        padding: EdgeInsets.all(value.padding2),
        child: Wrap(children: formItems)
    );
  }

  _buildPasswordTextFormField() {
    var formItems = <Widget>[
      TextFormField(
          autofillHints: const [AutofillHints.password],
          style: TextStyle(color: palette.of(context).textColor),
          controller: passwordController,
          keyboardType: TextInputType.text,
          obscureText: true,
          enableSuggestions: true,
          autocorrect: false,
          decoration: _formInputDecoration("비밀번호"),
          onChanged: (text) => setState(() {
            if(text.isNotEmpty) {
              if(text.length >= value.minPasswordLength) {
                isPasswordFilled = true;
                return;
              }
            }
            isPasswordFilled = false;
          })
      ),
      _formAlertContainer(isWrongPassword, "잘못된 비밀번호입니다"),
    ];
    return Container(
        padding: EdgeInsets.all(value.padding2),
        child: Wrap(children: formItems)
    );
  }

  _buildButtonContainer() {
    var buttonItems = <Widget>[
      Material(
          borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
          color: _activate()?palette.of(context).buttonBgColor:Colors.transparent,
          child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
              splashColor: _activate()?palette.of(context).buttonFgColor:Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              highlightColor: (_activate())?null:Colors.transparent,
              child: _buildButtonInnerContainer(),
              onTap: () => _buttonClickListener()
          )
      ),
    ];
    return Container(
        padding: EdgeInsets.all(value.padding2),
        child: Wrap(children: buttonItems)
    );
  }

  _activate() {
    return isEmailFilled && isPasswordFilled;
  }

  _buildButtonInnerContainer() {
    return Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: value.buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
          border: Border.all(
              color: _activate()?Colors.transparent: palette.of(context).secondary,
              width: 1
          ),
        ),
        child: Text(
          "로그인",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: _activate()?palette.of(context).buttonTextColor:palette.of(context).secondary,
              fontSize: value.caption1
          ),
        )
    );
  }

  _buttonClickListener() {
    if(_activate() && !isLoading) {
      final email = emailController.text;
      final password = passwordController.text;
      setState(() {
        isLoading = true;
        isWrongPassword = false;
        isUnknownAccount = false;
        account = AccountManager();
        account.loginWithEmail(email, password).then((value) {
          setState(() {
            if (value == account.authorized) {
              TextInput.finishAutofillContext();
              _setPreferences("Email").then((value) => _buildNavigator());
            } else if (value == account.wrongPassword) {
              isWrongPassword = true;
            }  else {
              isUnknownAccount = true;
            }
            isLoading = false;
          });
        });
      });
    }
  }

  _buildGoogleButton() {
    return Container(
        margin: EdgeInsets.only(
            right: value.margin2,
            left: value.margin2,
            top: value.margin3,
            bottom: value.margin3
        ),
        child: Material(
            borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
            color: palette.of(context).systemWhite,
            child: InkWell(
                splashFactory: NoSplash.splashFactory,
                splashColor: palette.of(context).buttonFgColor,
                borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
                child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    padding: EdgeInsets.only(
                        left: value.padding2,
                        right: value.padding2
                    ),
                    height: value.buttonHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
                    ),
                    child: Stack(
                      children: [
                        Container(
                            alignment: Alignment.centerLeft,
                            child: Image.asset("image/google_icon.png",
                                width: value.iconSmall1,
                                height: value.iconSmall1
                            )
                        ),
                        Container(
                            alignment: Alignment.center,
                            child: Text("Google 계정으로 로그인하기",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: palette.of(context).systemGrey,
                                fontSize: value.caption1,
                                fontFamily: "Roboto",
                              ),
                            )
                        )
                      ],
                    )
                ),
                onTap: () => setState(() {
                  isLoading = true;
                  _signInGoogle().then((user) {
                    account = SimpleAccountManager();
                    account.init(uid: user.uid, userName: user.displayName);
                    _simpleLogin("Google");
                  });
                })
            )
        )
    );
  }

  _signInGoogle() async {
    UserCredential auth;
    if(kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
      googleProvider.setCustomParameters({
        'login_hint': 'user@example.com'
      });
      auth = await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser
          ?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      auth = await FirebaseAuth.instance.signInWithCredential(credential);
    }
    return auth.user;
  }

  _buildKakaoButton() {
    return Container(
        margin: EdgeInsets.only(
            right: value.margin2,
            left: value.margin2,
            top: value.margin3,
            bottom: value.margin3
        ),
        child: Material(
            borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
            color: Color(0xfffee500),
            child: InkWell(
                splashFactory: NoSplash.splashFactory,
                borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
                child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    padding: EdgeInsets.only(
                        left: value.padding2,
                        right: value.padding2
                    ),
                    height: value.buttonHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
                    ),
                    child: Stack(
                      children: [
                        Container(
                            alignment: Alignment.centerLeft,
                            child: Image.asset("image/kakao_icon.png",
                                width: value.iconSmall1,
                                height: value.iconSmall1
                            )
                        ),
                        Container(
                            alignment: Alignment.center,
                            child: Text("카카오톡으로 로그인하기",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: palette.of(context).systemGrey,
                                  fontSize: value.caption1,
                                  fontFamily: "Roboto"
                              ),
                            )
                        )
                      ],
                    )
                ),
                onTap: () => _signInKakao().then((user) {
                  if(user != null) {
                    account = SimpleAccountManager();
                    account.init(uid: user.id, userName: user.kakaoAccount?.profile?.nickname);
                    _simpleLogin("Kakao");
                  }
                })
            )
        )
    );
  }

  _signInKakao() async {
    if (await Kakao.isKakaoTalkInstalled()) {
      await Kakao.UserApi.instance.loginWithKakaoTalk();
      return await Kakao.UserApi.instance.me();
    } else {
      dialog.createAlertDialog("카카오톡을 실행할 수 없습니다", [dialog.confirmButton()]);
      return null;
    }
  }

  _buildNavigator() {
    return Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, anim, secondary) => const TabMain(),
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

  _simpleLogin(platform) async {
    try {
      bool initial = await account.isInitial();
      if(!initial) {
        await _setPreferences(platform);
        _buildNavigator();
        isLoading = false;
        return;
      } else {
        dialog.createAlertDialog("가입하겠습니까?", [
          dialog.dismissButton(),
          CupertinoButton(
              child: const Text("확인"),
              onPressed: () => _createAccount(platform))
        ]);
      }
    } catch(e) {
      dialog.createAlertDialog("문제가 발생했습니다", [dialog.confirmButton()]);
      isLoading = false;
    }
  }

  _createAccount(platform) async {
    final userName = await account.getUserName();
    await account.create();
    UserManager user = UserManager(account.getUid());
    await user.create(
        UserFactory.User(
            name: userName,
            colors: []
        )
    );
    await _setPreferences(platform);
    _buildNavigator();
    isLoading = false;
  }

  _setPreferences(platform) async {
    final pref = await SharedPreferences.getInstance();
    pref.setBool("initial-run", false);
    pref.setString("uid", account.getUid());
    pref.setString("platform", platform);
  }
}