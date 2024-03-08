import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '/fn/dialog_manager.dart';
import '/src/color_palette.dart';
import '/src/system_value.dart';


class ItemAddPage extends StatefulWidget {
  const ItemAddPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ItemAddPage();
  }
}

class _ItemAddPage extends State<ItemAddPage> {
  var value = SystemValue();
  var palette = ColorPalette();
  var dialog = DialogManager();

  String changedName = "";
  late final TextEditingController nameController;
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CupertinoNavigationBar(
            backgroundColor: palette.of(context).background,
            middle: Text("이름", style: TextStyle(color: palette.of(context).textColor))
        ),
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
    dialog.setContext(context);
    nameController = TextEditingController();
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
                if (changedName.isNotEmpty) {
                  isLoading = true;
                  Navigator.of(context).pop(changedName);
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
            changedName = value;
          }
        )
    );
  }
}


