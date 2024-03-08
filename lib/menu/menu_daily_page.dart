import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/enum/categories_enum.dart';
import '/enum/chart_enum.dart';
import '/factory/consumption_item_factory.dart';
import '/fn/account_bank_manager.dart';
import '/fn/account_manager.dart';
import '/fn/date_manager.dart';
import '/fn/dialog_manager.dart';
import '/fn/money_manager.dart';
import '/fn/user_manager.dart';
import '/src/color_palette.dart';
import '/src/system_value.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class DailyAnalysisPage extends StatefulWidget {
  final UserManager user;
  final dynamic account;
  final DateManager date;
  const DailyAnalysisPage({required this.user, required this.account, required this.date, super.key});

  @override
  createState() {
    return _DailyAnalysisPage();
  }
}

class _DailyAnalysisPage extends State<DailyAnalysisPage> {
  late final UserManager user;
  late final dynamic account;
  late final DateManager date;
  late final BankManager bank;

  final value = SystemValue();
  final dialog = DialogManager();
  final palette = ColorPalette();
  final money = MoneyManager();

  @override
  build(BuildContext context) {
    return Scaffold(
        backgroundColor: palette.of(context).background,
        appBar: CupertinoNavigationBar(
          middle: Text(
            "일일 소비 분석",
            style: TextStyle(
                color: palette.of(context).textColor
            ),
          ),
          backgroundColor: palette.of(context).background,
        ),
        body: Container(
            padding: EdgeInsets.all(value.padding2),
            child: ListView(
                children: [
                  _buildTitleContainer(),
                  _buildCircularChart(),
                ]
            )
        )
    );
  }

  @override
  initState() {
    super.initState();
    user = widget.user;
    date = widget.date;
    bank = user.getBank();
    account = widget.account;
    dialog.setContext(context);
    final today = DateManager(init: true);
    if(today.compareDate(date.getDate()) > 0) {
        date.initDate();
    }
  }

  _buildTitleContainer() {
    return Container(
        padding: EdgeInsets.all(value.padding4),
        child: Center(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Container(
                          padding: EdgeInsets.all(value.padding3),
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            size: value.iconSmall3,
                            color: palette.of(context).systemBlue,
                          )
                      ),
                      onTap: () => setState(() {
                        date.decreaseDate();
                      })
                  ),
                  Container(
                      padding: EdgeInsets.all(value.padding2),
                      child: Text(
                          date.toString(),
                          style: TextStyle(
                            fontSize: value.body,
                            fontWeight: FontWeight.bold,
                            color: palette.of(context).textColor,
                          )
                      )
                  ),
                  InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Container(
                          padding: EdgeInsets.all(value.padding3),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: value.iconSmall3,
                            color: palette.of(context).systemBlue,
                          )
                      ),
                      onTap: () => setState(() {
                        DateManager today = DateManager();
                        today.initDate();
                        if(date.getCalendar() < today.getCalendar()) date.increaseDate();

                      })
                  )
                ]
            )
        )
    );
  }
  _buildCircularChart() {
    Map<String, double> map = {};
    int count = bank.getItemCount(date.getCalendar());
    double etc = 0;
    double total = 0;
    for(int index = 0; index < count; index++) {
      ConsumptionItem item = bank.getItem(date.getCalendar(), index);
      total += item.getItemCost();
      if(item.itemCategory == Category.etc.idx) {
        etc += item.getItemCost();
      } else {
        String label = Category.values[item.itemCategory].label;
        if(!map.containsKey(label)) map[label] = 0;
        map[label] = map[label]! + item.getItemCost();
      }
    }

    map = Map.fromEntries(map.entries.toList()..sort((e1, e2)=> e1.value.compareTo(e2.value)));
    map = Map.fromEntries(map.entries.toList().reversed);
    List label = [];
    List data = [];

    for(var key in map.keys) {
      if(map[key]! * 20 >= total) {
        label.add(key);
        data.add(map[key]);
      } else {
        if(label.last == Category.etc.label) {
          data.last += map[key];
        } else {
          label.add(Category.etc.label);
          data.add(map[key]);
        }
      }
    }

    if(etc > 0) {
      if(label.last == Category.etc.label) {
        data.last += etc;
      } else {
        label.add(Category.etc.label);
        data.add(etc);
      }
    }


    return Wrap(
      children: [
        _buildChartContainer(label, data, total),
        _buildListContainer(label, data, total)
      ]
    );
  }

  _buildChartContainer(label, data, total) {
    return Container(
        decoration: BoxDecoration(
            color: palette.of(context).primary,
            borderRadius: BorderRadius.all(Radius.circular(value.radius1))
        ),
        padding: EdgeInsets.all(value.padding2),
        margin: EdgeInsets.all(value.margin3),
        child: (label.isNotEmpty)?
        SfCircularChart(
            legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                textStyle: TextStyle(
                    color: palette.of(context).textColor,
                    fontSize: value.caption1
                )
            ),
            margin: const EdgeInsets.all(0),
            tooltipBehavior: TooltipBehavior(
                enable: true,
                format: 'point.x'
            ),
            series: <CircularSeries>[
              DoughnutSeries<ChartData, String>(
                dataSource: List.generate(label.length, (index) =>
                    ChartData(label: label[index], data: data[index].round())
                ),
                enableTooltip: true,
                animationDuration: 1000,
                animationDelay: 0,
                xValueMapper: (data, _) => data.label,
                yValueMapper: (data, _) => data.data,
                dataLabelMapper: (datum, index) => "${(datum.data / total * 100).round()}%",
                dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelIntersectAction: LabelIntersectAction.hide,
                    labelPosition: ChartDataLabelPosition.inside,
                    textStyle: TextStyle(
                        color: palette.of(context).systemWhite,
                        fontSize: value.caption2,
                        fontWeight: FontWeight.bold
                    )
                ),
              )
            ]

        ):
        Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(value.padding2),
            child: Text(
                "데이터가 없습니다",
                style: TextStyle(
                    fontSize: value.caption1,
                    color: palette.of(context).textColor
                )
            )
        )
    );
  }

  _buildListContainer(label, data, total) {
    List<Widget> items = List.generate(label.length, (index) {
      return Container(
          width: double.infinity,
          margin: EdgeInsets.all(value.margin2),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "${index+1}. ${label[index]}",
                    style: TextStyle(
                      fontSize: value.body,
                      color: palette.of(context).textColor,
                    )
                ),
                Text(
                    money.numberToKorean(data[index].toInt()),
                    style: TextStyle(
                      fontSize: value.body,
                      color: palette.of(context).textAccent,
                    )
                )
              ]
          )
      );
    });

    return Visibility(
        visible: (items.isNotEmpty),
        child: Container(
            decoration: BoxDecoration(
                color: palette.of(context).primary,
                borderRadius: BorderRadius.all(Radius.circular(value.radius1))
            ),
            padding: EdgeInsets.all(value.padding2),
            margin: EdgeInsets.all(value.margin3),
            child: Wrap(
                children: [
                  Wrap(children: items),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: palette.of(context).accent,
                  ),
                  Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(value.margin2),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                "전체",
                                style: TextStyle(
                                  fontSize: value.body,
                                  color: palette.of(context).textColor,
                                )
                            ),
                            Text(
                                money.numberToKorean(total.round()),
                                style: TextStyle(
                                  fontSize: value.body,
                                  color: palette.of(context).textAccent,
                                )
                            )
                          ]
                      )
                  )
                ]
            )
        )
    );
  }
}


