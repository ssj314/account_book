import '/fn/date_manager.dart';
import '/fn/dialog_manager.dart';
import '/fn/money_manager.dart';
import '/src/color_palette.dart';
import '/src/system_value.dart';
import '/summary/summary_inner_page.dart';
import '../fn/user_manager.dart';
import 'package:flutter/material.dart';

class SummaryPage extends StatefulWidget {
  final UserManager user;
  const SummaryPage({required this.user, super.key});

  @override
  State<StatefulWidget> createState() {
    return _SummaryPage();
  }
}

class _SummaryPage extends State<SummaryPage> {
  late final UserManager user;
  final value = SystemValue();
  final palette = ColorPalette();
  final dialog = DialogManager();
  final date = DateManager();
  final money = MoneyManager();

  final mode = true;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: palette.of(context).background,
        padding: EdgeInsets.only(
          left: value.padding2,
          right: value.padding2,
        ),
        child: ListView(
            primary: false,
            children: <Widget>[
              Container(height: value.padding2),
              _buildTopContainer(),
              SummaryInnerPage(user: user, date: date),
              Container(height: value.padding2)
            ]
        )
    );
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
    date.initDate();
    dialog.setContext(context);
  }

  _buildTopContainer() {
    return Container(
        padding: EdgeInsets.only(
          top:value.padding1,
          left: value.padding3,
          right: value.padding3,
          bottom: value.padding4,
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildButtonRow()
            ]
        )
    );
  }

  _buildButtonRow() {
    return Row(children: [
      Material(
          color: palette.of(context).primary,
          borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
          child: InkWell(
              splashColor: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
              onTap: () => setState(() {
                if(date.getCurrentYear() == date.getYear()) {
                  date.decreaseMonth();
                } else if(date.getCurrentYear() - date.getYear() == 1) {
                  if(date.getMonth() > 2) date.decreaseMonth();
                }
              }),
              child: Container(
                  padding: EdgeInsets.all(value.padding4),
                  child: Icon(
                      Icons.arrow_back_ios_outlined,
                      size: value.iconSmall3,
                      color: palette.of(context).accent
                  )
              )
          )
      ),
      Container(width: value.margin2),
      Material(
        borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
        color: palette.of(context).primary,
        child: InkWell(
            splashColor: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
            onTap: () => setState(() {
              if(!date.isCurrentMonth()) date.increaseMonth();

            }),
            child: Container(
                padding: EdgeInsets.all(value.padding4),
                child: Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: value.iconSmall3,
                    color: palette.of(context).accent
                )
            )
        ),
      )]
    );
  }
}
