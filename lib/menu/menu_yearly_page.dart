import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/enum/chart_enum.dart';
import '/fn/account_bank_manager.dart';
import '/fn/date_manager.dart';
import '/fn/money_manager.dart';
import '/fn/user_manager.dart';
import '/src/color_palette.dart';
import '/src/system_value.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class YearlyAnalysisPage extends StatefulWidget {
  final UserManager user;
  final dynamic account;
  final DateManager date;
  const YearlyAnalysisPage({required this.user, required this.account, required this.date, super.key});

  @override
  createState() {
    return _YearlyAnalysisPage();
  }
}

class _YearlyAnalysisPage extends State<YearlyAnalysisPage> {
  late final UserManager user;
  late final dynamic account;
  late final DateManager date;
  late final BankManager bank;

  final value = SystemValue();
  final palette = ColorPalette();
  final money = MoneyManager();

  DateManager start = DateManager();
  DateManager end = DateManager();

  @override
  build(BuildContext context) {
    return Scaffold(
        backgroundColor: palette.of(context).background,
        appBar: CupertinoNavigationBar(
          backgroundColor: palette.of(context).background,
          middle: Text(
              "연간 소비 분석",
              style: TextStyle(
                color: palette.of(context).textColor
              ),
          ),
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
    account = widget.account;
    bank = user.getBank();
  }

  _initDate() {
    start = date.copy();
    end = date.copy();
    start.setDate(bank.getPayday());
    end.setDate(bank.getPayday());
    (date.getCurrentDate() < bank.getPayday())? start.decreaseMonth():end.increaseMonth();
    end.decreaseDate();
  }

  _buildTitleContainer() {
    _initDate();
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
                  if(date.getCurrentYear() - date.getYear() < 2) {
                    date.decreaseMonth();
                  } else {
                    for(int i = 0; i < 11; i++) {
                      date.increaseMonth();
                    }
                  }
                })
              ),
              Container(
                padding: EdgeInsets.all(value.padding2),
                child: Text(
                    "${date.getYear()}",
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

                    for(int i = 0; i < 23; i++) {
                      date.increaseMonth();
                      if(date.isCurrentMonth()) break;
                    }

                  })
              )
            ]
          )
        )
    );
  }

  _buildCircularChart() {
    List labelList = [];
    List dataList = [];
    int total = date.getMonth();
    for(int i = 0; i < total; i++) {
      int srt = start.getCalendar();
      int fn = end.getCalendar();
      labelList.add("${start.getMonth()}");
      dataList.add(bank.getTotalExp(srt, fn));
      date.decreaseMonth();
      _initDate();
    }
    date.increaseMonth();
    return Wrap(
        children: [
          _buildChartContainer(total, labelList, dataList),
          //_buildListContainer(dataMap, total)
        ]
    );
  }

  _buildChartContainer(length, label, data) {
    return Container(
        decoration: BoxDecoration(
            color: palette.of(context).primary,
            borderRadius: BorderRadius.all(Radius.circular(value.radius1))
        ),
        padding: EdgeInsets.all(value.padding2),
        margin: EdgeInsets.all(value.margin3),
        child: (length > 0)?
        SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
              controller: ScrollController(),
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: length * 84.0,
                child: SfCartesianChart(
                    enableAxisAnimation: true,
                    plotAreaBorderColor: Colors.transparent,
                    primaryYAxis: const NumericAxis(isVisible: false),
                    primaryXAxis: CategoryAxis(
                        majorGridLines: const MajorGridLines(color: Colors.transparent),
                        // minorGridLines: const MinorGridLines(color: Colors.transparent),
                        majorTickLines: const MajorTickLines(color: Colors.transparent),
                        // minorTickLines: const MinorTickLines(color: Colors.transparent),
                        isInversed: true,
                        labelStyle: TextStyle(
                          color: palette.of(context).complementary,
                          fontSize: value.caption2,
                        )
                    ),
                    series: [
                      ColumnSeries(
                        initialSelectedDataIndexes: const [0],
                        width: 0.75,
                        enableTooltip: false,
                        selectionBehavior: SelectionBehavior(
                            enable: true,
                            selectedColor: palette.of(context).systemBlue,
                            unselectedColor: palette.of(context).systemGrey,
                        ),
                        dataLabelMapper: (datum, index) => "${money.numberToKorean(datum.data)}",
                        dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            textStyle: TextStyle(
                                color: palette.of(context).textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: value.caption3
                            )
                        ),
                        color: palette.of(context).systemGrey,
                        isTrackVisible: true,
                        // isVisible: true,
                        isVisibleInLegend: true,
                        dataSource: List.generate(length,
                                (index) {
                              return ChartData(
                                  label: label[index],
                                  data: data[index]
                              );
                            }
                        ),
                        xValueMapper: (chart, _) => "${chart.label}월",
                        yValueMapper: (chart, _) => chart.data,

                      )
                    ]
                )
              )
          )
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
}



