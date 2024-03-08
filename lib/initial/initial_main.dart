import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/initial/initial_login.dart';
import '/initial/initial_register.dart';
import '/src/color_palette.dart';
import '/src/system_value.dart';

class InitialMainPage extends StatelessWidget {
  InitialMainPage({super.key});
  final value = SystemValue();
  final palette = ColorPalette();
  final title = "";
  final subTitle1 = "";
  final subTitle2 = "";

  @override
  Widget build(BuildContext context) {
    return  Container(
        color: palette.of(context).background,
        child: Scaffold(
            backgroundColor: palette.of(context).background,
            body: Container(
                padding: EdgeInsets.all(value.padding2),
                child: Stack(
                    children: [
                      _buildInfoContainer(context),
                      _buildButtonContainer(context)
                    ]
                )
            )
        )
    );
  }

  _buildInfoContainer(context) {
    final infoItems = [
      Container(
          padding: EdgeInsets.all(value.padding2),
          child: Image.asset(
            "image/brand_icon.png",
            color: palette.of(context).systemBlue,
            height: value.iconLarge1,
            width: value.iconLarge1,
          )
      ),
      Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(value.padding2),
          child: Text(title,
              style: TextStyle(
                  color: palette.of(context).textColor,
                  fontSize: value.title2,
                  fontWeight: FontWeight.bold
              )
          )
      ),
      Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(value.padding4),
          child: Text(subTitle1,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: palette.of(context).textColor,
                  fontSize: value.body
              )
          )
      ),
      Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(value.padding4),
          child: Text(subTitle2,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: palette.of(context).textColor,
                  fontSize: value.body
              )
          )
      ),
      Container(
        padding: EdgeInsets.all(value.padding1),
      )
    ];
    return Center(
      child: Wrap(
          alignment: WrapAlignment.center,
          children: infoItems
      )
    );
  }

  _buildButtonContainer(context) {
    final buttonItems = <Widget>[
      _buildRegisterButtonContainer(context),
      Container(height: value.margin1),
      _buildLoginButtonContainer(context)
    ];
    return Container(
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.all(value.padding2),
        child: Wrap(children: buttonItems)
    );
  }

  _buildRegisterButtonContainer(context) {
    return Material(
        color: palette.of(context).buttonBgColor,
        borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
        child: InkWell(
            borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
            splashFactory: NoSplash.splashFactory,
            splashColor: palette.of(context).buttonFgColor,
            onTap: () => _buildNavigator(context, const InitialRegisterPage()),
            child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: value.buttonHeight,
                child: Text(
                    "가입하기",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: palette.of(context).buttonTextColor,
                        fontSize: value.body
                    )
                )
            )
        )
    );
  }

  _buildLoginButtonContainer(context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              alignment: Alignment.center,
              child: Text("이미 계정이 있나요?",
                  style: TextStyle(color: palette.of(context).textColor, fontSize: value.caption1)
              )
          ),
          Container(width: value.padding3),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Container(
                alignment: Alignment.center,
                child: Text("로그인하기",
                    style: TextStyle(color: palette.of(context).textAccent, fontSize: value.caption1)
                )
            ),
            onTap: () => _buildNavigator(context, const InitialLoginPage()),
          )
        ]
    );
  }

  _buildNavigator(context, page) {
    return Navigator.of(context).push(
        PageRouteBuilder(
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
}
