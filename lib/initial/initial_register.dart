import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as Kakao;
import '/factory/user_factory.dart' as UserFactory;
import '/fn/account_manager.dart';
import '/fn/dialog_manager.dart';
import '/fn/simple_account_manager.dart';
import '/fn/user_manager.dart';
import '/src/color_palette.dart';
import '/src/system_value.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../tab/tab_main.dart';

class InitialRegisterPage extends StatefulWidget {
  const InitialRegisterPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _InitialRegisterPage();
  }
}

class _InitialRegisterPage extends State<InitialRegisterPage> {
  final value = SystemValue();
  final palette = ColorPalette();
  final dialog = DialogManager();
  late final dynamic account;

  var userNameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  var isEmailFilled = false;
  var isUserNameFilled = false;
  var isPasswordFilled = false;
  var isDuplicatedEmail = false;
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: palette.of(context).background,
        appBar: CupertinoNavigationBar(
          backgroundColor: palette.of(context).background,
          middle: Text("이메일로 가입하기",
              style: TextStyle(color: palette.of(context).textColor)
          ),
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
        child: Center(
            child: SpinKitFadingCube(
              color: palette.of(context).indicatorColor,
            )
        )
    );
  }

  _buildFormContainer() {
    final formItems = <Widget>[
      _buildEmailTextForm(),
      _buildUserNameForm(),
      _buildPasswordForm(),
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
      _buildKakaoButton(),
    ];
    return ListView(children: formItems);
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

  _buildEmailTextForm() {
    return Container(
        margin: EdgeInsets.all(value.margin2),
        child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            decoration: _formInputDecoration("이메일 주소"),
            style: TextStyle(color: palette.of(context).textColor),
            onChanged: (text) => setState(() {
              if(text.isNotEmpty) {
                if(RegExp(value.emailRegex).hasMatch(text)) {
                  isEmailFilled = true;
                  return;
                }
              }
              isEmailFilled = false;
            }),
        )
    );
  }

  _buildUserNameForm() {
    final nameFormItems = <Widget>[
      TextFormField(
          style: TextStyle(color: palette.of(context).textColor),
          maxLength: value.maxUserNameLength,
          keyboardType: TextInputType.text,
          controller: userNameController,
          decoration: _formInputDecoration("사용자 이름"),
          onChanged: (text) => setState(() {
            if(text.isNotEmpty) {
              if(value.maxUserNameLength >= text.length
                  && text.length >= value.minUserNameLength) {
                isUserNameFilled = true;
                return;
              }
            }
            isUserNameFilled = false;
          })
      ),
      _formAlertContainer(!isUserNameFilled, "최소 4자리 이상, 최대 15자 이하")
    ];
    return Container(
      margin: EdgeInsets.all(value.margin2),
      child: Wrap(children: nameFormItems)
    );
  }

  _buildPasswordForm() {
    final passwordFormItems = <Widget>[
      TextFormField(
          style: TextStyle(color: palette
              .of(context)
              .textColor),
          obscureText: true,
          maxLength: 20,
          onChanged: (text) =>
              setState(() {
                if (text.isNotEmpty) {
                  if (value.maxPasswordLength >= text.length
                      && text.length >= value.minPasswordLength) {
                    isPasswordFilled = true;
                    return;
                  }
                }
                isPasswordFilled = false;
              }),
          keyboardType: TextInputType.emailAddress,
          controller: passwordController,
          decoration: _formInputDecoration("비밀번호")
      ),
      _formAlertContainer(!isPasswordFilled, "최소 6자리 이상, 최대 20자리 이하")
    ];

    return Container(
        margin: EdgeInsets.all(value.margin2),
        child: Wrap(children: passwordFormItems)
    );
  }

  _buildButtonContainer() {
    var buttonItems = <Widget>[
      Material(
          borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
          color: palette.of(context).buttonBgColor,
          child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
              splashColor: palette.of(context).buttonFgColor,
              splashFactory: NoSplash.splashFactory,
              child: _buildButtonInnerContainer(),
              onTap: () => _buttonClickListener()
          )
      ),
      _formAlertContainer(isDuplicatedEmail, "이미 존재하는 계정입니다")
    ];
    return Container(
      margin: EdgeInsets.all(value.margin2),
      child: Wrap(children: buttonItems)
    );
  }

  _buildButtonInnerContainer() {
    return Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: value.buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
        ),
        child: Text(
          "가입하기",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: palette.of(context).buttonTextColor,
              fontSize: value.caption1
          ),
        )
    );
  }

  _buttonClickListener() {
    setState(() {
      if(isUserNameFilled && isEmailFilled && isPasswordFilled && !isLoading) {
        final userName = userNameController.text;
        final email = emailController.text;
        final password = passwordController.text;

        isLoading = true;
        isDuplicatedEmail = false;
        account = AccountManager();
        account.init(userName, email, password);
        account.isDuplicatedEmail().then((value) {
          if(value as bool) {
            isDuplicatedEmail = true;
          } else {
            isDuplicatedEmail = false;
            _createAccount("Email");
          }
          isLoading = false;
        });
      }
    });
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
                        child: Text("Google 계정으로 가입하기",
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
                _signInGoogle().then((user) {
                  account = SimpleAccountManager();
                  account.init(uid: user.uid, userName: user.displayName);
                  _createAccount("Google");
                });
              })
          )
        )
    );
  }

  _signInGoogle() async {
    UserCredential? auth;
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope(
          'https://www.googleapis.com/auth/contacts.readonly');
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
            color: const Color(0xfffee500),
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
                            child: Text("카카오톡으로 시작하기",
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
                onTap: () => _signInKakao()
            )
        )
    );
  }

  _signInKakao() async {
    if(await Kakao.isKakaoTalkInstalled()) {
      Kakao.OAuthToken token = await Kakao.UserApi.instance.loginWithKakaoTalk();
      Kakao.User user = await Kakao.UserApi.instance.me();
      setState(() {
        account = SimpleAccountManager();
        dialog.createAlertDialog(user.id.toString(), []);
        account.init(uid: user.id.toString(), userName: user.kakaoAccount?.profile?.nickname);
        _createAccount("Kakao");
      });
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

  _createAccount(platform) async {
    try {
      if(platform != "Email") {
        bool initial = await account.isInitial();
        if(!initial) {
          await _setPreferences(platform);
          _buildNavigator();
          return;
        }
      }

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
    } catch(e) {
      dialog.createAlertDialog("문제가 발생했습니다", [dialog.confirmButton()]);
    }
  }

  _setPreferences(platform) async {
    final pref = await SharedPreferences.getInstance();
    pref.setBool("initial-run", false);
    pref.setString("uid", account.getUid());
    pref.setString("platform", platform);
  }
}