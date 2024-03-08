import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_won/fn/account_bank_manager.dart';
import 'package:money_won/fn/date_manager.dart';
import 'package:money_won/fn/dialog_manager.dart';
import 'package:money_won/fn/money_manager.dart';
import 'package:money_won/fn/user_manager.dart';
import 'package:money_won/src/color_palette.dart';
import 'package:money_won/src/system_value.dart';
import 'package:money_won/summary/summary_memo_page.dart';

class SummaryInnerPage extends StatefulWidget {
  final UserManager user;
  final DateManager date;
  const SummaryInnerPage({required this.user, required this.date, super.key});

  @override
  State<StatefulWidget> createState() {
    return _SummaryInnerPage();
  }
}

class _SummaryInnerPage extends State<SummaryInnerPage> {
  late final UserManager user;
  late final DateManager date;
  late final BankManager bank;

  final value = SystemValue();
  final palette = ColorPalette();
  final dialog = DialogManager();
  final money = MoneyManager();

  late PageController controller;
  DateManager start = DateManager();
  DateManager end = DateManager();

  DateManager partStart = DateManager();
  DateManager partEnd = DateManager();

  var isFirstDateSelected = false;
  var isLastDateSelected = false;
  var selectionMode = false;

  final expText = "지출";
  final limitText = "소비 계획";

  @override
  Widget build(BuildContext context) {
    return Wrap(
        children: [
          GestureDetector(
              onHorizontalDragEnd: (DragEndDetails value) {
                setState(() {
                  if(value.primaryVelocity != null) {
                    if (value.primaryVelocity! > 100) { // 감소
                      date.decreaseMonth();
                    } else if (value.primaryVelocity! < -100) { //증가
                      if(!date.isCurrentMonth()) {
                        date.increaseMonth();
                      }
                    }
                    date.isCurrentMonth()?date.initDate():date.setDate(0);
                  }
                });
              },
              child: _buildBodyContainer()
          ),
          Column(children: _buildEndContainer())
        ]
    );
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
    date = widget.date;
    bank = user.getBank();
    dialog.setContext(context);
    controller = PageController();
  }

  _buildNavigator(page) {
    return Navigator.of(context).push(PageRouteBuilder(
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
            ))
    );
  }

  // 상단부

  _buildBodyContainer() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
          color: palette.of(context).primary,
        ),
        margin: EdgeInsets.all(value.margin3),
        padding: EdgeInsets.all(value.margin3),
        child: Wrap(
          children: [
            Table(children: [_buildLabel()]),
            Table(children: _buildCalendarRow())
          ]
        )
    );
  }

  _buildLabel(){
    final weekLabel = ["S", "M", "T", "W", "T", "F", "S"];
    final labelContainer = <Widget>[];
    final colors = [palette.of(context).textAlert, palette.of(context).textColor, palette.of(context).textColor,
      palette.of(context).textColor, palette.of(context).textColor, palette.of(context).textColor, palette.of(context).textAccent];
    for(int i = 0; i < 7; i++) {
      labelContainer.add(Container(
          margin: EdgeInsets.only(top: value.margin3, bottom: value.margin2),
          child: Center(child:Text(weekLabel[i],
              style: TextStyle(
                  color: colors[i],
                  fontSize: value.body
              )
          ))
      ));
    }
    return TableRow(children: labelContainer);
  }

  _buildCalendarRow() {
    start = date.copy();
    end = date.copy();
    start.setDate(bank.getPayday());
    end.setDate(bank.getPayday());
    (date.getCurrentDate() < bank.getPayday())? start.decreaseMonth():end.increaseMonth();
    end.decreaseDate();

    var week = 1;
    final items = <TableRow>[];
    final firstDay = (DateTime.parse(start.getCalendar().toString()).weekday);
    while(true) {
      final weekContainer = <Widget>[];
      for (var day = 0; day < 7; day++) {
        if (week == 1 && day < firstDay || start.getCalendar() > end.getCalendar()) {
          weekContainer.add(Container());
          continue;
        }
        if(isFirstDateSelected && isLastDateSelected) {
          if(partStart.getCalendar() <= start.getCalendar() && start.getCalendar() <= partEnd.getCalendar()) {
            weekContainer.add(_buildCalendarText(start.copy(), true));
            start.increaseDate();
            continue;
          }
        }
        weekContainer.add(_buildCalendarText(start.copy(), false));
        start.increaseDate();
      }
      items.add(TableRow(children: weekContainer));
      if(start.getCalendar() > end.getCalendar()) break;
      week++;
    }
    start.decreaseMonth();
    return items;
  }

  _buildCalendarText(date, part) {
    var calendar = date.getCalendar();
    var color = Colors.transparent;

    if(date.compareDate(date.getDate()) == 0) {
      color = palette.of(context).systemTeal;
    }

    if(isFirstDateSelected) {
      if(calendar == partStart.getCalendar()) {
        color = palette.of(context).systemIndigo;
      } else if(part) {
        color = palette.of(context).systemIndigo;
      }
    }

    return InkWell(
        child: Stack(
            children: [
              Container(
                margin: EdgeInsets.all(value.margin4),
                child: Visibility(
                    visible: bank.hasMemo(calendar),
                    child: (bank.hasMemo(calendar) && bank.getMemo(calendar).important)?
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: Icon(Icons.star_outlined,
                        color: palette.of(context).systemPink,
                        size: 8,
                      ),
                    ):
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: (bank.hasMemo(calendar))?palette.of(context).defaultMemoColor:null,
                            borderRadius: BorderRadius.all(Radius.circular(value.radius3))
                        )
                      ),
                    )
                )
              ),
              Column(children: [
                Container(
                  width: value.boxSize,
                  height: value.boxSize,
                  margin: EdgeInsets.only(top: value.margin3),
                  decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.all(Radius.circular(value.radius1))
                  ),
                  child: _buildDateContainer(date, part),
                ),
                _buildTraceContainer(calendar)],
              ),

            ]
        ),
        onTap: () => setState(() {
          if(!selectionMode) {
            _buildNavigator(MemoPage(user: user, date: date)).then((value) => setState(() {}));
          } else {
            if(isLastDateSelected) {
              isFirstDateSelected = false;
              isLastDateSelected = false;
              selectionMode = false;
            } else if(partStart.getCalendar() == calendar) {
              isFirstDateSelected = false;
              selectionMode = false;
            } else {
              isLastDateSelected = true;
              if(calendar < partStart.getCalendar()) {
                partEnd = partStart;
                partStart = DateManager.fromString(calendar);
              } else {
                partEnd = DateManager.fromString(calendar);
              }
            }
          }
        }),
        onLongPress: () => setState(() {
          isLastDateSelected = false;
          isFirstDateSelected = true;
          selectionMode = true;
          partStart = DateManager.fromString(calendar);
        })
    );
  }

  _buildDateContainer(date, part) {
    final calendar = date.getCalendar();
    var textColor = palette.of(context).textColor;
    if(date.compareDate(date.getDate()) == 0) {
      textColor = Colors.white;
    } else if(date.compareDate(date.getDate()) < 0) {
      textColor = palette.of(context).accent;
    }

    if(isFirstDateSelected) {
      if(calendar == partStart.getCalendar()) {
        textColor = palette.of(context).systemWhite;
      } else if(part) {
        textColor = palette.of(context).systemWhite;
      }
    }

    return Container(
        alignment: Alignment.center,
        child: Text("${date.getDate()}",
            style: TextStyle(
                color: textColor,
                fontSize:value.body
            )
        )
    );
  }

  _buildTraceContainer(calendar) {
    final expenditure = bank.getExp(calendar);
    final limit = bank.getLimit(calendar);
    var color = (limit < expenditure)?palette.of(context).textAlert:palette.of(context).textAccent;

    return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: value.margin3, bottom: value.margin4),
        child: Column(
            children: [
              Text("$limit",
                  style: TextStyle(
                      fontSize: value.smallCaption,
                      color: (limit >= 0)?palette.of(context).accent:Colors.transparent
                  )
              ),
              Text("$expenditure",
                  style: TextStyle(
                      fontSize: value.caption3,
                      color: (expenditure > 0)?color:Colors.transparent
                  )
              )
            ]
        )
    );
  }

  // 하단부

  _buildEndContainer() {
    var isVisible = isFirstDateSelected || isLastDateSelected;
    final items = <Widget>[
      Visibility(
          visible: isVisible,
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
                  color: palette.of(context).primary
              ),
              padding: EdgeInsets.all(value.padding2),
              margin: EdgeInsets.all(value.margin3),
              child: _buildPartialTotalContainer()
          )
      ),
      Visibility(
          visible: !isVisible,
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
                  color: palette.of(context).primary
              ),
              padding: EdgeInsets.all(value.padding2),
              margin: EdgeInsets.all(value.margin3),
              child: _buildTotalContainer()
          )
      )
    ];
    return items;
  }

  _buildTotalContainer() {
    final expenditure = bank.getTotalExp(start.getCalendar(), end.getCalendar());
    final limit = bank.getTotalLimit(start.getCalendar(), end.getCalendar());
    final color = (limit < expenditure) ? palette.of(context).textAlert : palette.of(context).textAccent;

    return Column(children: [
      Container(
          alignment: Alignment.centerLeft,
          child: Container(
              margin: EdgeInsets.only(
                  left: value.margin3,
                  top: value.margin3
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("요약",
                      style: TextStyle(
                          color: palette.of(context).textColor,
                          fontSize: value.title2,
                          fontWeight: FontWeight.bold
                      )
                  ),
                  Container(
                    padding: EdgeInsets.only(right: value.margin3),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          final date = this.date.copy();
                          date.setDate(0);
                          _buildNavigator(MemoPage(user: user, date: date));
                        });
                      },
                      child: Icon(
                        CupertinoIcons.bubble_right_fill,
                        color: palette.of(context).defaultMemoColor,
                        size: value.iconSmall3,
                      )
                    )
                  )
                ]
              )
          )
      ),
      Container(
        alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(
              left: value.margin3,
              bottom: value.margin3
          ),
          child: Text("(${start.toString()} ~ ${end.toString()})",
          style: TextStyle(
            color: palette.of(context).accent,
            fontSize: value.caption2,
          ),
        )
      ),
      _buildExpenditureContainer(text: expText, color: color, total: expenditure),
      _buildLimitContainer(text: limitText, expected: limit)
    ]);
  }

  _buildPartialTotalContainer() {
    DateManager start;
    DateManager end;
    if(isLastDateSelected) {
      start = partStart;
      end = partEnd;
    } else {
      if(this.start.getCalendar() <= partStart.getCalendar()) {
        start = this.start;
        end = partStart;
      } else {
        start = partStart;
        end = this.start;
      }
    }
    final expenditure = bank.getTotalExp(start.getCalendar(), end.getCalendar());
    final limit = bank.getTotalLimit(start.getCalendar(), end.getCalendar());
    final color = (limit < expenditure) ? palette.of(context).textAlert : palette.of(context).textAccent;

    return Column(children: [
      Container(
          alignment: Alignment.centerLeft,
          child: Container(
              margin: EdgeInsets.only(
                  left: value.margin3,
                  top: value.margin3
              ),
              child: Text("구간 요약",
                  style: TextStyle(
                      color: palette.of(context).textColor,
                      fontSize: value.title2,
                      fontWeight: FontWeight.bold
                  )
              )
          )
      ),
      Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(
              left: value.margin3,
              bottom: value.margin3
          ),
          child: Text("(${start.toString()} ~ ${end.toString()})",
            style: TextStyle(
              color: palette.of(context).accent,
              fontSize: value.caption2,
            ),
          )
      ),
      _buildExpenditureContainer(text: expText, color: color, total: expenditure),
      _buildLimitContainer(text: limitText, expected: limit)
    ]);
  }

  _buildExpenditureContainer({required text, required total, required color}) {
    return Container(
        padding: EdgeInsets.all(value.margin3),
        child: Row(
            children: [
              Image.asset("image/monthly_total.png",
                  color: palette.of(context).systemBlue,
                  width: value.iconRegular3
              ),
              Container(
                  padding: EdgeInsets.only(left: value.padding1),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(text,
                            style: TextStyle(
                                color: palette.of(context).textColor,
                                fontSize: value.caption2
                            )
                        ),
                        Text("${money.currency.format(total)}원",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: (total == 0)?palette.of(context).textColor:color,
                                fontSize: value.title3
                            )
                        )
                      ]
                  )
              )
            ]
        )
    );
  }

  _buildLimitContainer({required text, required expected}) {
    String expectedStr = (expected < 0)?"미지정":"${money.currency.format(expected)}원";
    return Container(
        padding: EdgeInsets.all(value.margin3),
        child: Row(
            children: [
              Image.asset("image/monthly_expect.png",
                  color: palette.of(context).systemBlue,
                  width: value.iconRegular3
              ),
              Container(
                  padding: EdgeInsets.only(left: value.padding1),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(text,
                            style: TextStyle(
                                color: palette.of(context).textColor,
                                fontSize: value.caption2
                            )
                        ),
                        Text(expectedStr,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: palette.of(context).textColor,
                                fontSize: value.title3
                            )
                        )
                      ]
                  )
              )
            ]
        )
    );
  }
}
