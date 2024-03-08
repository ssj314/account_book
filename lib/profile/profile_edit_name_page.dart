import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '/fn/dialog_manager.dart';
import '/fn/user_manager.dart';
import '/src/color_palette.dart';
import '/src/system_value.dart';


class ProfileNameEditPage extends StatefulWidget {
  final UserManager user;
  final dynamic account;
  const ProfileNameEditPage({required this.user, required this.account, super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProfileNameEditPage();
  }
}

class _ProfileNameEditPage extends State<ProfileNameEditPage> {
  late final UserManager user;
  late final dynamic account;

  var value = SystemValue();
  var dialog = DialogManager();
  var palette = ColorPalette();

  late String changedName;
  late TextEditingController nameController;

  var isLoading = false;

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
                      _buildIconContainer(),
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
    account = widget.account;
    dialog.setContext(context);
    changedName = user.getName();
    nameController = TextEditingController(text: changedName);
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
                final changedName = nameController.text;
                if (changedName != user.getName()) {
                  isLoading = true;
                  _rename().then((value) {
                    Navigator.of(context).pop();
                    isLoading = false;
                  });
                }
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
    );
  }

  _buildIconContainer() {
    return Container(
      padding: EdgeInsets.all(value.margin2),
      alignment: Alignment.topCenter,
      child: InkWell(
          onTap: () {},
          child: Icon(Icons.account_circle,
              color: palette.of(context).secondary,
              size: value.iconLarge3
          )
      ),
    );
  }

  _buildInputContainer() {
    return Container(
        height: value.buttonHeight,
        margin: EdgeInsets.all(value.margin1),
        width: value.modalHeightSmall,
        child: TextFormField(
          maxLength: value.maxUserNameLength,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: palette.of(context).textColor,
            fontSize: value.title3,
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
          },
        )
    );
  }

  _rename() async {
    await user.setName(changedName);
    await account.setUserName(changedName);
  }
}


