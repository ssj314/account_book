import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '/fn/account_bank_manager.dart';
import '/fn/dialog_manager.dart';
import '/fn/user_manager.dart';
import '/src/color_palette.dart';
import '/src/system_value.dart';


class BankNameEditPage extends StatefulWidget {
  final UserManager user;
  final int index;
  final bool mode;
  const BankNameEditPage({required this.user, this.mode = true, this.index = -1, super.key});

  @override
  State<StatefulWidget> createState() {
    return _BankNameEditPage();
  }
}

class _BankNameEditPage extends State<BankNameEditPage> {
  var value = SystemValue();
  var palette = ColorPalette();
  var dialog = DialogManager();

  late final int index;
  late final UserManager user;
  late final BankManager bank;
  late final List bankNames;
  late final TextEditingController nameController;
  
  var isLoading = false;
  var name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: palette.of(context).background,
        appBar: CupertinoNavigationBar(backgroundColor: palette.of(context).background),
        body: Container(
          color: palette.of(context).background,
          padding: EdgeInsets.all(value.padding2),
          child: Stack(
              children: [
                Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Container(height: value.margin1),
                      _buildInputContainer()
                    ]
                ),
                _buildButtonContainer(),
                _buildIndicator()
              ]
          )
        )
    );
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
    index = widget.index;
    dialog.setContext(context);
    
    bank = user.getBank();
    bankNames = bank.getList();

    nameController = TextEditingController(text: (widget.mode)?'':bankNames[index]);
  }

  _buildIndicator() {
    return Visibility(
        visible: isLoading,
        child: Center(child: SpinKitFadingCube(color: palette.of(context).systemBlue))
    );
  }

  _buildButtonContainer() {
    return Container(
      margin: EdgeInsets.all(value.margin2),
      alignment: Alignment.bottomCenter,
      child: Material(
          color: palette.of(context).systemBlue,
          borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
          child: InkWell(
              splashFactory: NoSplash.splashFactory,
              borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
              onTap: () => setState(() {
                if (name.isNotEmpty && !bankNames.contains(name)) {
                  isLoading = true;
                  if(widget.mode) {
                    bank.create(name).then((value) {
                      isLoading = false;
                      Navigator.of(context).pop(true);
                    });
                  } else {
                    bank.rename(name, index).then((value) {
                      isLoading = false;
                      Navigator.of(context).pop(true);
                    });
                  }
                } else {
                  dialog.createAlertDialog("다른 이름을 사용해주세요", [dialog.confirmButton()]);
                }
              }),
              child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: value.buttonHeight,
                  child: Text("확인",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: value.body,
                          color: palette.of(context).systemWhite
                      )
                  )
              )
          )
      )
    );
  }

  _buildInputContainer() {
    return Container(
        height: value.buttonHeight,
        margin: EdgeInsets.all(value.margin1),
        width: value.modalHeightSmall,
        child: TextFormField(
          maxLength: 10,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: palette.of(context).textColor,
            fontSize: value.title3,
            height: 1.0
          ),
          controller: nameController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              hintText: (widget.mode)?'':bankNames[index],
              hintStyle: TextStyle(color: palette.of(context).systemGrey),
              isDense: true,
              labelStyle: TextStyle(color: palette.of(context).textColor),
              contentPadding: EdgeInsets.symmetric(vertical: value.margin3),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 1, color: palette.of(context).systemBlue)
              ),
              counterText: ""
          ),
          onChanged: (value) {
            final TextSelection previousCursorPos = nameController.selection;
            nameController.text = value;
            nameController.selection = previousCursorPos;
            name = value;
          },
        )
    );
  }
}


