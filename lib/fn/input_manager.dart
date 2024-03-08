import 'package:flutter/material.dart';
import 'package:money_won/enum/MoneyController.dart';
import 'package:money_won/fn/dialog_manager.dart';
import 'package:money_won/fn/money_manager.dart';
import 'package:money_won/src/color_palette.dart';
import 'package:money_won/src/system_value.dart';

class InputManager extends StatefulWidget {
  final String title;
  final String body;
  final MoneyController controller;
  final List<Widget> buttons;
  const InputManager({this.title = "", this.body = "",
  required this.controller, required this.buttons, super.key});

  @override
  State<StatefulWidget> createState() {
    return _InputManager();
  }
}

class _InputManager extends State<InputManager> {
  final palette = ColorPalette();
  final value = SystemValue();
  final money = MoneyManager();
  final dialog = DialogManager();
  final numberKey = [7, 8, 9, 4, 5, 6, 1, 2, 3];

  @override
  Widget build(BuildContext context) {
    return getContainer();
  }


  @override
  void initState() {
    super.initState();
    dialog.setContext(context);
  }

  getContainer() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.all(value.margin2),
          color: Colors.transparent,
          child: Material(
              color: Colors.transparent,
              child: Container(
                  padding: EdgeInsets.all(value.padding2),
                  decoration: BoxDecoration(
                      color: palette.of(context).background,
                      border: Border.all(color: palette.of(context).primary, width: 1),
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
                                    widget.title,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: value.body,
                                        color: palette.of(context).textColor
                                    )
                                )
                            ),
                            Center(
                                child: IconButton(
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: palette.of(context).secondary,
                                      size: value.iconSmall1,
                                    ),
                                    onPressed: () => Navigator.of(context).pop()
                                )
                            )
                          ],
                        ),
                        Container(
                            width: double.infinity,
                            height: 48,
                            margin: EdgeInsets.only(
                                left: value.margin3,
                                right: value.margin3
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(width: 1.5, color: palette.of(context).systemBlue)
                              )
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("변경할 내역",
                                  style: TextStyle(
                                      color: palette.of(context).textAccent,
                                      fontSize: value.caption2,
                                      height: 1.5
                                  ),
                                ),
                                Text(
                                  widget.controller.text,
                                  style: TextStyle(
                                      color: palette.of(context).textColor,
                                      fontSize: value.body,
                                      height: 1.5
                                  )
                                )
                              ]
                            )
                        ),
                        Container(
                          margin: EdgeInsets.only(top: value.margin2),
                          child: getKeyPad(),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: widget.buttons
                        )
                      ]
                  )
              )
          )
      )
    );
  }

  getKeyPad() {
    final keyRow = <Widget>[];
    for(int i = 0; i < 3; i++) {
      final items = <Widget>[];
      for (int j = 0; j < 3; j++) {
        items.add(_buildNumberButton(numberKey[j + i * 3]));
      }
      keyRow.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items
      ));
    }
    keyRow.add(_buildSpecialButton());
    return Container(
        height: value.keyPadHeight,
        color: palette.of(context).background,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: keyRow
        )
    );
  }

  _buildNumberButton(int number) {
    return TextButton(
        style: TextButton.styleFrom(
          minimumSize: Size(value.keyPadButtonWidth, value.keyPadButtonHeight),
          splashFactory: NoSplash.splashFactory,
          foregroundColor: Colors.white
        ),
        child: Text(
            "$number",
            style: TextStyle(
                color: palette.of(context).textColor,
                fontSize: value.body
            )
        ),
        onPressed: () => setState(() {
          int balance = 0;
          if(widget.controller.text.isNotEmpty) {
            balance = money.koreanToNumber(widget.controller.text);
            if(balance * 10 + number > money.maxBalanceLimit) {
              dialog.createAlertDialog("100억을 초과할 수 없습니다", [dialog.confirmButton()]);
              return;
            }
            balance *= 10;
          }
          balance += number;
          widget.controller.text = money.numberToKorean(balance);
        })
    );
  }

  _buildSpecialButton() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHundredButton(),
          _buildZeroButton(),
          _buildBackButton()
        ]
    );
  }

  _buildHundredButton() {
    return TextButton(
        style: TextButton.styleFrom(
            minimumSize: Size(value.keyPadButtonWidth, value.keyPadButtonHeight),
            splashFactory: NoSplash.splashFactory,
            foregroundColor: Colors.white
        ),
        child: Text("00",
            style: TextStyle(
                color: palette.of(context).textColor,
                fontSize: value.body
            )
        ),
        onPressed: () => setState(() {
          if (widget.controller.text.isNotEmpty) {
            int balance = money.koreanToNumber(widget.controller.text);
            if (balance > 0) {
              if (balance * 100 > money.maxBalanceLimit) {
                dialog.createAlertDialog(
                    "100억을 초과할 수 없습니다",
                    [dialog.confirmButton()]
                );
              } else {
                balance *= 100;
                widget.controller.text = money.numberToKorean(balance);
              }
            }
          }
        })
    );
  }

  _buildZeroButton() {
    return TextButton(
        style: TextButton.styleFrom(
            minimumSize: Size(value.keyPadButtonWidth, value.keyPadButtonHeight),
            splashFactory: NoSplash.splashFactory,
            foregroundColor: Colors.white
        ),
        child: Text("0",
            style: TextStyle(
              color: palette.of(context).textColor,
              fontSize: value.body
            )
        ),
        onPressed: () => setState(() {
          if(widget.controller.text.isNotEmpty) {
            int balance = money.koreanToNumber(widget.controller.text);
            if(balance > 0) {
              if(balance * 10 > money.maxBalanceLimit) {
                dialog.createAlertDialog(
                    "100억을 초과할 수 없습니다",
                    [dialog.confirmButton()]
                );
              } else {
                balance *= 10;
                widget.controller.text = money.numberToKorean(balance);
              }
            }
          } else {
            widget.controller.text = "0원";
          }
        })
    );
  }

  _buildBackButton() {
    return TextButton(
        style: TextButton.styleFrom(
            minimumSize: Size(value.keyPadButtonWidth, value.keyPadButtonHeight),
            splashFactory: NoSplash.splashFactory,
            foregroundColor: Colors.white
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          size: value.iconSmall3,
          color: palette.of(context).buttonBgColor,
        ),
        onPressed: () => setState(() {
          if(widget.controller.text.isNotEmpty) {
            int balance = money.koreanToNumber(widget.controller.text);
            if (balance >= 10) {
              balance = (balance / 10).floor();
              widget.controller.text = money.numberToKorean(balance);
            } else {
              widget.controller.text = "";
            }
          } else {
            Navigator.of(context).pop();
          }
        })
    );
  }
}