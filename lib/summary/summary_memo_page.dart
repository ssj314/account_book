import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:money_won/factory/memo_factory.dart';
import 'package:money_won/fn/account_bank_manager.dart';
import 'package:money_won/fn/date_manager.dart';
import 'package:money_won/fn/dialog_manager.dart';
import 'package:money_won/fn/user_manager.dart';
import 'package:money_won/src/system_value.dart';

import '../src/color_palette.dart';

class MemoPage extends StatefulWidget {
  final UserManager user;
  final DateManager date;
  const MemoPage({required this.user, required this.date, super.key});

  @override
  State<StatefulWidget> createState() {
    return _MemoPage();
  }
}

class _MemoPage extends State<MemoPage> {
  late final UserManager user;
  late final DateManager date;
  late final BankManager bank;
  late final Memo memo;
  late final List colors;
  late final TextEditingController controller;

  final value = SystemValue();
  final palette = ColorPalette();
  final textFocus = FocusNode();
  final dialog = DialogManager();

  var isLoading = false;
  var textColor = true;
  var isInitial = true;
  var expanded = false;

  @override
  Widget build(BuildContext context) {
    if(isInitial) {
      if(bank.hasMemo(date.getCalendar())) {
        memo = bank.getMemo(date.getCalendar());
      } else {
        memo = Memo(
            data: "",
            important: false,
            memoColor: palette.of(context).defaultMemoColor.value
        );
      }
      controller = TextEditingController(text: memo.data);
      isInitial = false;
    }
    final color = Color(memo.getColor());
    textColor = ((color.red * 299 + color.green * 587 + color.blue * 114) / 1000 > 125)?true:false;
    return Container(
        color: palette.of(context).background,
        child: SafeArea(
            child: Scaffold(
                backgroundColor: palette.of(context).background,
                appBar: CupertinoNavigationBar(
                    backgroundColor: palette.of(context).background,
                    middle: Text(date.toString(),
                        style: TextStyle(
                            color: palette.of(context).textColor
                        )
                    ),
                    trailing: InkWell(
                      child: Icon((memo.important)?
                      Icons.star:Icons.star_outline_sharp,
                        size: value.iconSmall2,
                        color: palette.of(context).defaultMemoColor,
                      ),
                      onTap: () => setState(() => memo.important = !memo.important),
                    )
                ),
                body: Stack(
                    children: [
                      Container(
                          color: palette.of(context).background,
                          padding: EdgeInsets.all(value.padding2),
                          child: ListView(
                            children: [
                              _buildMemoContainer(),
                              Container(height: value.margin2),
                              _buildExpandButtonContainer(),
                              Container(height: value.margin2),
                              _buildColorContainer(),
                              Container(height: value.margin2),
                              _buildDeleteButtonContainer(),
                              Container(height: 120),
                            ],
                          )
                      ),
                      Container(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: EdgeInsets.all(value.padding2),
                            child: _buildButtonContainer(),
                          )
                      ),
                      _buildIndicator()
                    ]
                )
            )

        )
    );
  }

  @override
  void initState() {
    super.initState();
    date = widget.date;
    user = widget.user;
    bank = user.getBank();
    colors = user.getSavedColors();
    dialog.setContext(context);
  }

  _buildIndicator() {
    return Visibility(
        visible: isLoading,
        child: Center(child: SpinKitFadingCube(color: palette.systemBlue))
    );
  }

  _buildPaletteContainer() {
    return Wrap(
      children: [
        Container(
            padding: EdgeInsets.all(value.padding3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                return InkWell(
                    child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: (colors.length > index)?Color(colors[index]):palette.of(context).accent,
                            borderRadius: BorderRadius.all(Radius.circular(value.radiusModal))
                        )
                    ),
                    onTap: () {
                      setState(() {
                        if(colors.length <= index) {
                          if(!colors.contains(memo.memoColor)) {
                            colors.add(memo.memoColor);
                          }
                          if(colors.length == 10) {
                            colors.removeAt(0);
                          }
                        } else {
                          memo.memoColor = colors[index];
                        }
                        user.setSavedColors(colors);
                      });
                    },
                  onLongPress: () {
                    setState(() {
                      if(colors.length > index) {
                        colors.removeAt(index);
                      }
                      user.setSavedColors(colors);
                    });
                  },
                );
              }),
            )
        ),
        Container(
            padding: EdgeInsets.all(value.padding3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                return InkWell(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: (colors.length > index + 5)?Color(colors[index + 5]):palette.of(context).accent,
                          borderRadius: BorderRadius.all(Radius.circular(value.radiusModal))
                      )
                    ),
                    onTap: () {
                      setState(() {
                        if(colors.length <= index + 5) {
                          if(!colors.contains(memo.memoColor)) {
                            colors.add(memo.memoColor);
                          }

                          if(colors.length > 10) {
                            colors.removeAt(0);
                          }
                        } else {
                          memo.memoColor = colors[index + 5];
                        }
                        user.setSavedColors(colors);
                      });
                    },
                    onLongPress: () {
                      setState(() {
                        if(colors.length > index + 5) {
                          colors.removeAt(index + 5);
                        }
                        user.setSavedColors(colors);
                      });
                    },
                );
              }),
            )
        )
      ],
    );
  }
  _buildColorContainer() {
    return Container(
        padding: EdgeInsets.all(value.padding3),
        decoration: BoxDecoration(
            color: palette.of(context).primary,
            borderRadius: BorderRadius.all(Radius.circular(value.radius1))
        ),
        child: Column(
          children: [
            _buildPaletteContainer(),
            SlidePicker(
                sliderSize: const Size(double.infinity, 36),
                enableAlpha: false,
                displayThumbColor: false,
                sliderTextStyle: TextStyle(color: palette.of(context).textColor),
                showIndicator: false,
                showParams: false,
                pickerColor: Color(memo.memoColor),
                onColorChanged: (Color color) {
                  setState(() {
                    textFocus.unfocus();
                    memo.memoColor = color.value;
                  });
                }
            ),
          ]
        )
      );
  }

  _buildMemoContainer() {
    return AnimatedContainer(
        padding: EdgeInsets.all(value.padding1),
        decoration: BoxDecoration(
            color:  Color(memo.memoColor),
            borderRadius: BorderRadius.all(Radius.circular(value.radius1))
        ),
        height: (expanded)?value.memoExpanded:value.memoHeight,
        duration: const Duration(milliseconds: 100),
        child: TextFormField(
          decoration: InputDecoration(
              border: InputBorder.none,
              counterStyle: TextStyle(color: textColor?Colors.black:Colors.white)
          ),
          minLines: 100,
          maxLines: null,
          maxLength: 200,
          keyboardType: TextInputType.multiline,
          focusNode: textFocus,
          onTapOutside: (event) => setState(() => textFocus.unfocus()),
          controller: controller,
          style: TextStyle(
              fontFamily: 'CustomFont',
              fontSize: value.body,
              fontWeight: FontWeight.bold,
              color: (textColor)?palette.of(context).systemBlack:palette.of(context).systemWhite,
              height: 1.4
          )
        )
    );
  }

  _buildButtonContainer() {
    return Material(
        color: palette.of(context).systemBlue,
        borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
        child: InkWell(
            splashFactory: NoSplash.splashFactory,
            borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
            child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: value.buttonHeight,
                child: Text("저장",
                    style: TextStyle(color: palette.of(context).systemWhite, fontSize: value.body)
                )
            ),
            onTap: () => setState(() {
              if(!isLoading) {
                textFocus.unfocus();
                isLoading = true;
                if (controller.text.isNotEmpty || controller.text != "") {
                  memo.data = controller.text;
                  bank.setMemo(date.getCalendar(), memo).then((value) => setState(() {
                    Navigator.of(context).pop();
                    isLoading = false;
                  }));
                } else {
                  bank.removeMemo(date.getCalendar()).then((value) => setState(() {
                      Navigator.of(context).pop();
                      isLoading = false;
                    })
                  );
                }
              }
            })
        )
    );
  }

  _buildExpandButtonContainer() {
    return Container(
      alignment: Alignment.center,
      child: InkWell(
        child: Icon(
            (expanded)?Icons.keyboard_arrow_up_rounded:Icons.keyboard_arrow_down_rounded,
            color: palette.of(context).complementary,
            size: value.iconSmall1
        ),
        onTap: () {
          setState(() {
            expanded = !expanded;
          });
        },
      )
    );
  }

  _buildDeleteButtonContainer() {
    return Visibility(
        visible: bank.hasMemo(date.getCalendar()),
        child: InkWell(
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(value.padding3),
                child: Text("삭제",
                    style: TextStyle(
                        color: palette.of(context).textAlert,
                        fontSize: value.caption1
                    )
                )
            ),
            onTap: () => setState(() {
              dialog.createAlertDialog("메모를 삭제하겠습니까?", [
                dialog.dismissButton(),
                CupertinoButton(
                    child: const Text("확인"),
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        Navigator.of(context).pop();
                        bank.removeMemo(date.getCalendar()).then((value) {
                          Navigator.of(context).pop();
                          isLoading = false;
                        });
                      });
                    })
              ]);
            })
        )
    );
  }
}
