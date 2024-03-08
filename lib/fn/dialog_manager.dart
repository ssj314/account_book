import 'package:flutter/cupertino.dart';
import 'package:money_won/src/color_palette.dart';

import '../src/system_value.dart';

class DialogManager {
  late BuildContext context;
  final palette = ColorPalette();
  final value = SystemValue();

  setContext(BuildContext context) {
    this.context = context;
  }

  void createAlertDialog(String content, List<CupertinoButton> button) {
    _dialog("안내", content, button);
  }

  confirmButton() {
    return CupertinoButton(
        minSize: value.buttonHeight,
        child: Text("확인",
            style: TextStyle(
                color: palette.of(context).textAccent
            )
        ),
        onPressed: () => Navigator.of(context).pop()
    );
  }

  dismissButton() {
    return CupertinoButton(
        minSize: value.buttonHeight,
        child: Text("취소",
            style: TextStyle(
                color: palette.of(context).textAlert
            )
        ),
        onPressed: () => Navigator.of(context).pop()
    );
  }

  void _dialog(title, content, buttons) {
    showCupertinoDialog(
        context: context,
        builder: (value) =>
            CupertinoAlertDialog(
                title: Text(title),
                content: Text(content),
                actions: buttons
            )
    );
  }
}



