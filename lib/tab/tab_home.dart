import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '/enum/MoneyController.dart';
import '/enum/categories_enum.dart';
import '/factory/consumption_item_factory.dart';
import '/fn/account_bank_manager.dart';
import '/fn/date_manager.dart';
import '/fn/dialog_manager.dart';
import '/fn/input_manager.dart';
import '/fn/money_manager.dart';
import '/home/home_inner_page.dart';
import '/menu/menu_daily_page.dart';
import '/src/color_palette.dart';
import '/src/system_value.dart';
import '../fn/user_manager.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserManager user;
  final dynamic account;
  const HomePage({required this.user, required this.account, super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  late final UserManager user;
  late final BankManager bank;
  late final dynamic account;

  final value = SystemValue();
  final palette = ColorPalette();
  final dialog = DialogManager();
  final money = MoneyManager();

  static DateManager date = DateManager();

  var onYearClick = false;
  var onMonthClick = false;
  var isExpanded = false;

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
            )
    )
    );
  }

  @override
  Widget build(BuildContext context) {
    bank.syncBank(date.getCalendar());
    return Container(
        color: palette.of(context).background,
        padding: EdgeInsets.only(
          left: value.padding2,
          right: value.padding2,
        ),
        child: Container(
            color: palette.of(context).background,
            child: ListView(
                physics: const ClampingScrollPhysics(),
                primary: false,
                children: <Widget>[
                  Container(height: value.margin2),
                  _buildTopContainer(),
                  GestureDetector(
                      onHorizontalDragEnd: (DragEndDetails value) {
                        setState(() {
                          if(value.primaryVelocity != null) {
                            if (value.primaryVelocity! > 100) { // 감소
                              date.decreaseMonth();
                              date.isCurrentMonth()?date.initDate():date.setDate(1);
                            } else if (value.primaryVelocity! < -100) { //증가
                              date.increaseMonth();
                              date.isCurrentMonth()?date.initDate():date.setDate(1);
                            }
                          }
                        });
                      },
                      child: _buildBodyContainer()
                  ),
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
                          color: palette.of(context).primary
                      ),
                      padding: EdgeInsets.all(value.padding2),
                      margin: EdgeInsets.all(value.margin3),
                      child: _buildTraceContainer()
                  ),
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
                          color: palette.of(context).primary
                      ),
                      padding: EdgeInsets.all(value.padding2),
                      margin: EdgeInsets.all(value.margin3),
                      child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      margin: EdgeInsets.all(value.margin3),
                                      child: Text("내역",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: value.title2,
                                            color: palette.of(context).textColor
                                        ),
                                      )
                                  ),
                                  Container(
                                      margin: EdgeInsets.all(value.margin3),
                                      child: InkWell(
                                          child: Icon(
                                              CupertinoIcons.arrow_down_left_square,
                                              color: palette.of(context).systemGrey,
                                              size: value.iconSmall2
                                          ), onTap: () => _buildNavigator(DailyAnalysisPage(user: user, account: account, date: date))
                                      )
                                  )
                                ]
                            ),
                            _buildItemContainer(),
                            Material(
                                color: Colors.transparent,
                                child: InkWell(
                                    borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
                                    highlightColor: palette.of(context).secondary,
                                    splashColor: Colors.transparent,
                                    child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(value.margin3),
                                        child: Icon(
                                            Icons.add_circle,
                                            size: value.iconSmall1,
                                            color: palette.of(context).systemBlue
                                        )
                                    ),
                                    onTap: () => setState(() {
                                      showModalBottomSheet(
                                          context: context,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) => _buildItemAddPopup(_buildItemCategoryContainer())
                                      );
                                    })
                                )
                            )
                          ]
                      )
                  ),
                  HomeInnerPage(user: user, date: date),
                  Container(height: value.margin2)
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
    bank = user.getBank();
    date.initDate();
    dialog.setContext(context);
    onYearClick = false;
    onMonthClick = false;
  }

  _buildTopContainer() {
    return Container(
        padding: EdgeInsets.only(
          top:value.padding1,
          left: value.padding2,
          right: value.padding2,
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildYearContainer(),
              Row(children: [
                _buildBankButton(),
                Container(width: value.margin2),
                _buildButtonRow()
              ])
            ]
        )
    );
  }

  _buildBankButton() {
    List bankList = bank.getList();
    int bankIndex = bank.getIndex();
    return InkWell(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  margin: EdgeInsets.all(value.margin3),
                  child: Text(
                      bankList[bankIndex],
                      style: TextStyle(
                          color: palette.of(context).systemGreen,
                          fontSize: value.caption2,
                          fontWeight: FontWeight.bold
                      )
                  )
              ),
              Icon(
                Icons.wallet,
                color: palette.systemGreen,
                size: value.iconSmall2,
              )
            ]
        ),
        onTap: () => showCupertinoModalPopup(
            context: context,
            builder: (context) => Container(
                margin: EdgeInsets.only(bottom: value.margin2),
                child: CupertinoActionSheet(
                    actions: List.generate(bankList.length, (index) {
                      return CupertinoButton(
                          minSize: value.buttonHeight,
                          child: Text(
                              "${bankList[index]}",
                              style: TextStyle(color: palette.of(context).textAccent)
                          ),
                          onPressed: () => setState(() {
                            bank.setIndex(index);
                            Navigator.of(context).pop();
                          })
                      );
                    }),
                    cancelButton: dialog.dismissButton()
                )
            )
        )
    );
  }

  _buildYearContainer() {
    return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Text(
            "${date.getYear()}",
            style: TextStyle(
                fontSize: value.largeTitle,
                color: onYearClick?palette.of(context).textAccent:palette.of(context).textColor
            )
        ),
        onTapDown: (value) => setState(() => onYearClick = true),
        onTapCancel: () => setState(() => onYearClick = false),
        onTapUp: (value) {
          setState(() {
            onYearClick = false;
            showModalBottomSheet(
                context: context,
                isDismissible: true,
                enableDrag: true,
                isScrollControlled: true,
                barrierColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                builder: (context) => _buildYearSelectPopup()
            );
          });
        }
    );
  }

  _buildButtonRow() {
    final labelMonth = ["Jan", "Feb", "Mar", "Apr", "May",
      "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return Row(children: [
      Container(
          margin: EdgeInsets.only(right: value.margin3),
          child: Material(
              color: palette.of(context).primary,
              borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
              child: InkWell(
                  splashFactory: NoSplash.splashFactory,
                  splashColor: palette.of(context).secondary,
                  borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
                  onTap: () => setState(() {
                    date.decreaseMonth();
                    date.isCurrentMonth()?date.initDate():date.setDate(1);
                  }),
                  child: Container(
                      padding: EdgeInsets.all(value.padding4),
                      child: Icon(
                          Icons.arrow_back_ios_outlined,
                          size: value.iconSmall3,
                          color: palette.of(context).secondary
                      )
                  )
              )
          )
      ),
      Container(
          width: 40,
          alignment: Alignment.center,
          child: InkWell(
              child: Text(labelMonth[date.getMonth()-1],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: value.body,
                      color: onMonthClick?palette.of(context).textAccent:palette.of(context).textColor
                  )
              ),
              onTapDown: (details) => setState(() => onMonthClick = true),
              onTapCancel: () => setState(() => onMonthClick = false),
              onTapUp: (details) {
                setState(() {
                  onMonthClick = false;
                  showModalBottomSheet(
                      isDismissible: true,
                      enableDrag: true,
                      isScrollControlled: true,
                      barrierColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) => _buildMonthSelectPopup()
                  );
                });
              }
          )
      ),
      Container(
          margin: EdgeInsets.only(left: value.margin3),
          child: Material(
            borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
            color: palette.of(context).primary,
            child: InkWell(
                splashFactory: NoSplash.splashFactory,
                splashColor: palette.of(context).secondary,
                borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
                onTap: () => setState(() {
                  date.increaseMonth();
                  date.isCurrentMonth()?date.initDate():date.setDate(1);
                }),
                child: Container(
                    padding: EdgeInsets.all(value.padding4),
                    child: Icon(
                        Icons.arrow_forward_ios_outlined,
                        size: value.iconSmall3,
                        color: palette.of(context).secondary
                    )
                )
            ),
          )
      )]
    );
  }



  _buildItemContainer() {
    final calendar = date.getCalendar();
    return Container(
        constraints: const BoxConstraints(maxHeight: 320),
        padding: EdgeInsets.all(value.padding3),
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: bank.getItemCount(calendar),
            itemBuilder: (context, index) {
              ConsumptionItem item = bank.getItem(calendar, index);
              int category = item.getItemCategory();
              return Material(
                color: Colors.transparent,
                child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
                    onLongPress: () => showCupertinoModalPopup(
                        context: context,
                        builder: (context) => Container(
                          margin: EdgeInsets.only(bottom: value.margin2),
                          child: CupertinoActionSheet(
                              actions: [
                                CupertinoButton(
                                    minSize: value.buttonHeight,
                                    child: Text(
                                        "삭제",
                                        style: TextStyle(color: palette.of(context).textAlert)
                                    ),
                                    onPressed: () => setState(() {
                                      bank.addBalance(item.getItemCost());
                                      bank.addExp(date.getCalendar(), -item.getItemCost());
                                      bank.removeItem(date.getCalendar(), index);
                                      Navigator.of(context).pop();
                                    })
                                )
                              ],
                              cancelButton: CupertinoButton(
                                  color: palette.of(context).systemWhite80,
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                      "취소",
                                      style: TextStyle(color: palette.of(context).textAccent)
                                  )
                              )
                          )
                        )
                    ),
                    child: Container(
                      margin: EdgeInsets.all(value.padding4),
                      child: Column(
                          children: [
                            Container(
                                padding: EdgeInsets.all(value.padding4),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Icon(
                                          Category.values[category].icon,
                                          size: value.iconSmall2,
                                          color: palette.of(context).systemBlue,
                                        )
                                      ),
                                      Container(
                                          margin: EdgeInsets.all(value.margin3),
                                          child: Text(
                                              Category.values[category].label,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  height: 1.0,
                                                  fontSize: value.caption1,
                                                  color: palette.of(context).textColor,
                                                  fontWeight: FontWeight.bold
                                              )
                                          )
                                      )
                                    ]
                                )
                            ),
                            Container(
                                padding: EdgeInsets.all(value.padding4),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          item.getItemName(),
                                          style: TextStyle(
                                              fontSize: value.body,
                                              color: palette.of(context).textColor
                                          )
                                      ),
                                      Text(
                                        "${money.numberToKorean(item.getItemCost())}",
                                        style: TextStyle(
                                            fontSize: value.body,
                                            color: palette.of(context).textAccent
                                        ),
                                      )
                                    ]
                                )
                            )
                          ]
                      ),
                    )
                )
              );
            }
        )
    );
  }

  _buildItemAddPopup(content) {
    return Container(
        margin: EdgeInsets.all(value.margin2),
        decoration: BoxDecoration(
            color: palette.of(context).background,
            borderRadius: BorderRadius.all(Radius.circular(value.radiusModal)),
            border: Border.all(width: 0.5, color: palette.of(context).primary)
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            content
          ]
        )
    );
  }

  _buildItemCategoryContainer() {
    int categoryIndex = 0;
    return Material(
        color: Colors.transparent,
        child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(value.padding2),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(value.margin3),
                  child: Text(
                    "카테고리",
                    style: TextStyle(
                        fontSize: value.title2,
                        color: palette.of(context).textColor,
                        fontWeight: FontWeight.bold
                    )
                  )
                ),
                Container(
                  margin: EdgeInsets.all(value.margin2),
                  height: 120,
                  width: double.infinity,
                  child: CupertinoPicker(
                      itemExtent: 40,
                      onSelectedItemChanged: (value) => setState(() {
                        categoryIndex = value;
                      }),
                      children: List.generate(Category.values.length,
                            (index) => Center(
                                child: Text(
                                    Category.values[index].label,
                                    style: TextStyle(
                                      color: palette.of(context).textColor
                                    ),
                                )
                            )
                      )
                  ),
                ),
                CupertinoButton(child: const Text("다음"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          enableDrag: true,
                          isScrollControlled: true,
                          context: context,
                          builder: (context) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  color: Colors.transparent,
                                  height: value.modalHeightXS,
                                  margin: EdgeInsets.all(value.margin4),
                                  child: Center(child: _buildItemAddPopup(_buildItemNameContainer(categoryIndex)))
                              ),
                              SizedBox(height: MediaQuery.of(context).viewInsets.bottom)
                            ]
                          )

                      );
                    }
                )
              ]
            )
        )
    );
  }

  _buildItemCostPopup(index, name) {
    MoneyController controller = MoneyController();
    return InputManager(
        title: "소비 금액 설정하기",
        body: "금액",
        controller: controller,
        buttons: [
          dialog.dismissButton(),
          CupertinoButton(child: const Text("확인"),
              onPressed: () => setState(() {
                int cost = money.koreanToNumber(controller.text);
                if(cost > 0) {
                  if(bank.getBalance() < cost) {
                    dialog.createAlertDialog("잔액이 부족합니다.", [
                      dialog.confirmButton()
                    ]);
                  } else {
                    bank.addItem(date.getCalendar(),
                        ConsumptionItem(
                            itemCategory: index,
                            itemName: (name.length > 0)? name:Category.values[index].label,
                            itemCost: cost
                        )
                    );
                    bank.addExp(date.getCalendar(), cost);
                    bank.addBalance(-cost);
                    nameController.text = "";
                    Navigator.of(context).pop();
                  }
                } else {
                  dialog.createAlertDialog("금액을 설정해주세요", [dialog.confirmButton()]);
                }
              })
          )
        ]
    );
  }

  TextEditingController nameController = TextEditingController();
  _buildItemNameContainer(index) {
    return Material(
        color: Colors.transparent,
        child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(value.padding2),
            child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Container(
                      padding: EdgeInsets.all(value.padding3),
                      child: Text(
                          "이름",
                          style: TextStyle(
                              fontSize: value.title2,
                              color: palette.of(context).textColor,
                              fontWeight: FontWeight.bold
                          )
                      )
                  ),
                  Container(
                      margin: EdgeInsets.all(value.margin3),
                      child: TextFormField(
                          maxLength: 10,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: palette.of(context).textColor,
                              fontSize: value.title3,
                              height: 1.0
                          ),
                          controller: nameController,
                          decoration: InputDecoration(
                              isDense: true,
                              counterText: "",
                              labelStyle: TextStyle(color: palette.of(context).textColor),
                              contentPadding: EdgeInsets.symmetric(vertical: value.margin2),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: palette.of(context).systemGrey),
                                borderRadius: BorderRadius.all(Radius.circular(value.radius2))
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: palette.of(context).systemBlue),
                                  borderRadius: BorderRadius.all(Radius.circular(value.radius1)),
                              ),
                              hintText: Category.values[index].label,
                              hintStyle: TextStyle(
                                color: palette.of(context).systemGrey,
                                fontSize: value.body
                              )
                          )
                      )
                  ),
                  CupertinoButton(child: const Text("확인"),
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.of(context).pop();
                        showModalBottomSheet(
                            useSafeArea: true,
                            backgroundColor: Colors.transparent,
                            enableDrag: true,
                            isScrollControlled: true,
                            isDismissible: true,
                            context: context,
                            builder: (context) => Container(
                                height: value.modalHeightLarge,
                                color: Colors.transparent,
                                alignment: Alignment.bottomLeft,
                                margin: EdgeInsets.all(value.padding4),
                                child:  _buildItemCostPopup(index, nameController.text)
                            )
                        );
                      }
                  )
                ]
            )
        )
    );
  }

  _buildMonthSelectPopup() {
    var month = date.getMonth();
    return Container(
        margin: EdgeInsets.all(value.margin2),
        padding: EdgeInsets.all(value.padding2),
        decoration: BoxDecoration(
            color: palette.of(context).primary,
            borderRadius: BorderRadius.all(Radius.circular(value.radiusModal)),
            border: Border.all(width: 0.5, color: palette.of(context).secondary)
        ),
        child: Material(
            color: Colors.transparent,
            child: Wrap(
                children: [
                  Container(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: Icon(Icons.close_rounded,
                              color: palette.of(context).secondary,
                              size: value.iconSmall1
                          ),
                          onTap: () => Navigator.of(context).pop()
                      )
                  ),
                  SizedBox(
                      height: value.modalHeightSmall,
                      child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(initialItem: month - 1),
                          itemExtent: 42,
                          onSelectedItemChanged: (int value) => setState(() => month = value + 1),
                          children: List.generate(12, (index) =>
                              Center(
                                  child: Text('${index + 1}월',
                                      style: TextStyle(color: palette.of(context).textColor)
                                  )
                              )
                          )
                      )
                  ),
                  Center(
                      child: CupertinoButton(
                          child: Text("확인",
                              style: TextStyle(
                                  color: palette.of(context).textAccent,
                                  fontSize: value.body
                              )),
                          onPressed: () => setState(() {
                            date.setMonth(month);
                            Navigator.of(context).pop();
                          })
                      )
                  )
                ]
            )
        )
    );
  }

  _buildYearSelectPopup() {
    return Container(
        margin: EdgeInsets.all(value.margin2),
        color: Colors.transparent,
        child: Material(
            color: Colors.transparent,
            child: Container(
                padding: EdgeInsets.all(value.padding2),
                decoration: BoxDecoration(
                    color: palette.of(context).primary,
                    border: Border.all(color: palette.of(context).secondary, width: 0.5),
                    borderRadius: BorderRadius.all(Radius.circular(value.radiusModal))
                ),
                child: _buildYearSelectContainer()
            )
        )
    );
  }

  _buildYearSelectContainer() {
    final items = <Widget>[
      Container(
        height: value.modalHeightSmall,
        alignment: Alignment.center,
        child: ListView(primary: false, children: _buildYearSelectWidget()),
      ),
      Center(
          child: CupertinoButton(
              padding: EdgeInsets.all(value.padding3),
              child: Text("취소", style: TextStyle(fontSize: value.body)),
              onPressed: () => Navigator.of(context).pop())
      )
    ];
    return  Wrap(children: items);
  }

  _buildYearSelectWidget() {
    List months = <Widget>[];
    for(int i = 24 + date.getCurrentMonth() - 1; i >= 0; i--) {
      int tempMonth = i % 12 + 1;
      int tempYear = (date.getCurrentYear() - 2) + (i / 12).floor();
      months.add(Container(
          alignment: Alignment.centerLeft,
          child: Material(
              borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
              color: Colors.transparent,
              child: InkWell(
                  splashFactory: NoSplash.splashFactory,
                  borderRadius: BorderRadius.all(Radius.circular(value.radius2)),
                  child: _buildYearItemContainer(tempYear, tempMonth),
                  onTap: () => _yearItemClickListener(tempYear, tempMonth)
              )
          )
      )
      );
    }
    return months;
  }

  _buildYearItemContainer(year, month) {
    return Container(
        padding: EdgeInsets.all(value.padding2),
        alignment: Alignment.centerLeft,
        child: Text(
            "$year년 $month월",
            style: TextStyle(
                color: (year == date.getYear() && month == date.getMonth())?
                palette.of(context).secondary:
                palette.of(context).textAccent,
                fontSize: value.body
            )
        )
    );
  }

  _yearItemClickListener(year, month) {
    setState(() {
      if(year != date.getYear() || month != date.getMonth()) {
        date.setYear(year);
        date.setMonth(month);
        if(date.isCurrentMonth()) {
          date.initDate();
        } else {
          date.setDate(1);
        }
      }
      Navigator.of(context).pop();
    });
  }

  // 하단부
  _buildBodyContainer() {
    List<Table> list = _buildCalendarButtonRow();
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
            Visibility(
                visible: !isExpanded,
                child: SizedBox(
                  height: 72,
                  child: PageView(
                    controller: PageController(initialPage: date.getSundayCount()),
                    children: list
                  )
              )
            ),
            Visibility(
                visible: isExpanded,
                child: Wrap(
                  children: list,
                )
            ),
            Container(
            alignment: Alignment.center,
            child: InkWell(
                child: Icon(
                    (isExpanded)?Icons.keyboard_arrow_up_rounded:Icons.keyboard_arrow_down_rounded,
                    color: palette.of(context).accent,
                    size: value.iconSmall1
                ),
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
              )
            )
          ],
        )
    );
  }

  _buildCalendarButtonRow() {
    var dateIndex = 1;
    final items = <Table>[];
    for (var week = 1; dateIndex <= date.getLastDate(); week++) {  // 주
      final weekContainer = <Widget>[];
      for (var day = 0; day < 7; day++) {  // 요일
        Container container;
        var today = dateIndex;
        if((week == 1 && day < date.getFirstDay()) || dateIndex > date.getLastDate()) {
          weekContainer.add(const Column(children: [Text("")]));
          continue;
        } else if (date.getDate() == today) {  // 선택한 날
          container = _buildSelectedBox(today, palette.of(context).systemBlue);
        } else if (date.compareDate(today) == 0) { // 오늘
          container = _buildSelectedBox(today, palette.of(context).systemTeal);
        } else {
          container = _buildDefaultBox(today);
        }
        weekContainer.add(_buildButton(container, today));
        dateIndex ++;
      }
      items.add(Table(children: [TableRow(children: weekContainer)]));
    }
    return items;
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

  _buildSelectedBox(date, color) {
    return Container(
        width: value.boxSize,
        height: value.boxSize,
        margin: EdgeInsets.only(top: value.margin4),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(value.radius1))
        ),
        child: Center(child: Text("$date",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: value.caption1)
        ))
    );
  }

  _buildDefaultBox(index) {
    return  Container(
        margin: EdgeInsets.only(
            top: value.margin4,
            bottom: value.margin2
        ),
        child: Text("$index",
            style: TextStyle(
                color: (date.compareDate(index) <= 0)?palette.of(context).secondary:palette.of(context).textColor,
                fontSize: value.caption1)
        )
    );
  }

  _buildButton(cont, today) {
    final calendar = date.getCalendar(date: today);
    final expenditure = bank.getExp(calendar);
    final limit = bank.getLimit(calendar);
    Color boxColor;

    if(limit < 0 || expenditure == 0) {
      boxColor = palette.of(context).secondary;
    } else if(expenditure > limit) {
      boxColor = palette.of(context).systemPink;
    } else {
      boxColor = palette.of(context).systemCyan;
    }

    return InkWell(
        onTap:() => setState(() => date.setDate(today)),
        child: Column(children: [
          Container(
              margin: EdgeInsets.only(top: value.margin4),
              width: value.boxSize,
              height: value.boxSize,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  border: Border.all(width: 1, color: Colors.transparent)
              ),
              child: Material(
                  color: boxColor,
                  borderRadius: BorderRadius.all(Radius.circular(value.radius3)),
                  child: InkWell(
                    splashFactory: NoSplash.splashFactory,
                    splashColor: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(value.radius3)),
                  )
              )
          ),
          cont]
      )
    );
  }

  _buildTraceContainer() {
    final items = <Widget>[
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                margin: EdgeInsets.all(value.margin3),
                child: Text("소비",
                    style: TextStyle(
                        color: palette.of(context).textColor,
                        fontSize: value.title2,
                        fontWeight: FontWeight.bold
                    )
                )
            ),
            Container(
                margin: EdgeInsets.all(value.margin3),
                child: Text(
                    "${date.getYear()}년 ${date.getMonth()}월 ${date.getDate()}일",
                    style: TextStyle(
                        color: palette.of(context).textAccent,
                        fontSize: value.caption1,
                        fontWeight: FontWeight.bold
                    )
                )
            )
          ]
      ),
      _buildLimitContainer(),
      _buildExpenditureContainer(),
      _buildDailyReportContainer()
    ];
    return Column(children: items);
  }

  _buildLimitContainer() {
    final calendar = date.getCalendar(date: date.getDate());
    final limit = bank.getLimit(calendar);
    final text = (limit < 0)?"미지정":"${money.currency.format(limit)}원";
    return Container(
        padding: EdgeInsets.all(value.margin3),
        child: InkWell(
            child: Row(
                children: [
                  Image.asset("image/daily_limit.png",
                      color: palette.of(context).systemBlue,
                      width: value.iconRegular3
                  ),
                  Container(
                      padding: EdgeInsets.only(left: value.padding1),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("한도",
                                style: TextStyle(
                                    color: palette.of(context).textColor,
                                    fontSize: value.caption2
                                )
                            ),
                            Text(text,
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
            ),
            onTap: () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                useSafeArea: true,
                enableDrag: true,
                isDismissible: true,
                builder: (context) => _buildLimitEditContainer(context)
            )
        )
    );
  }

  _buildExpenditureContainer() {
    final calendar = date.getCalendar(date: date.getDate());
    final expenditure = bank.getExp(calendar);
    return Container(
        padding: EdgeInsets.all(value.margin3),
        child: InkWell(
            child: Row(
                children: [
                  Image.asset("image/daily_expenditure.png",
                      color: palette.of(context).systemBlue,
                      width: value.iconRegular3
                  ),
                  Container(
                      padding: EdgeInsets.only(left: value.padding1),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("지출",
                                style: TextStyle(
                                    color: palette.of(context).textColor,
                                    fontSize: value.caption2
                                )
                            ),
                            Text("${money.currency.format(expenditure)}원",
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
            ),
            /*onTap: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (context) => _buildExpEditContainer(context, expenditure)
              );
            }*/
        )
    );
  }

  _buildDailyReportContainer() {
    final calendar = date.getCalendar(date: date.getDate());
    final limit = bank.getLimit(calendar);
    final expenditure = bank.getExp(calendar);
    final color = (limit < expenditure) ? palette.of(context).textAlert : palette.of(context).textAccent;
    return Visibility(
        visible: (limit > 0 && expenditure > 0),
        child: Container(
            padding: EdgeInsets.all(value.margin3),
            child: Row(
                children: [
                  SizedBox(
                      width: value.iconRegular3,
                      child: Image.asset("image/daily_report.png",
                          color: palette.of(context).systemBlue)
                  ),
                  Container(
                      padding: EdgeInsets.only(left: value.padding1),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text((expenditure > limit) ? "초과" : "잔여",
                                style: TextStyle(
                                    color: palette.of(context).textColor,
                                    fontSize: value.caption2
                                )
                            ),
                            Text(
                                "${money.currency.format((limit-expenditure).abs())}원",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (limit - expenditure == 0)?palette.of(context).textColor:color,
                                    fontSize: value.title3)
                            )
                          ]
                      )
                  )
                ]
            )
        )
    );
  }

  _buildExpEditContainer(context, int prev) {
    final calendar = date.getCalendar(date: date.getDate());
    final balance = bank.getBalance();
    final expenditure = bank.getExp(calendar);
    final controller = MoneyController();
    final buttons = [
      CupertinoButton(
          child: Text("수정",
              style: TextStyle(
                  color: palette.of(context).textAlert,
                  fontSize: value.body
              )
          ),
          onPressed: () {
            setState(() {
              if(controller.text.isNotEmpty) {
                int input = money.koreanToNumber(controller.text);
                if((input - expenditure) > balance) {
                  dialog.createAlertDialog("잔액이 부족합니다", [dialog.confirmButton()]);
                } else {
                  bank.addExp(calendar, input - prev);
                  bank.addBalance(prev - input);
                  Navigator.of(context).pop();
                }
              }
            });
          }
      ),
      CupertinoButton(
          child: Text("추가",
              style: TextStyle(
                  color: palette.of(context).textAccent,
                  fontSize: value.body
              )),
          onPressed: () {
            setState(() {
              if(controller.text.isNotEmpty) {
                int value = money.koreanToNumber(controller.text);
                if(value > balance) {
                  dialog.createAlertDialog("잔액이 부족합니다", [dialog.confirmButton()]);
                } else {
                  bank.addExp(calendar, value);
                  bank.addBalance(-value);
                  Navigator.of(context).pop();
                }
              }
            });
          }
      )
    ];

    return InputManager(title: "소비 내역 변경하기", body: "변경할 내역", controller: controller, buttons: buttons);
  }

  _buildLimitEditContainer(context) {
    final calendar = date.getCalendar(date: date.getDate());
    final controller = MoneyController();
    final buttons = [
      CupertinoButton(
          child: Text("삭제",
            style: TextStyle(
                color: palette.of(context).textAlert,
                fontSize: value.body
            )
          ),
          onPressed: () => setState(() {
            dialog.createAlertDialog("정말 한도를 없애겠습니까?", [
              dialog.dismissButton(),
              CupertinoButton(child: const Text("확인"), onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                setState(() {
                  bank.setLimit(calendar, -1);
                });
              })
            ]);
          })
      ),
      CupertinoButton(
          child: Text("확인",
              style: TextStyle(
                  color: palette.of(context).textAccent,
                  fontSize: value.body
              )),
          onPressed: () => setState(() {
            if(controller.text.isNotEmpty) {
              int value = money.koreanToNumber(controller.text);
              Navigator.of(context).pop();
              bank.setLimit(calendar, value).then((value) => setState(() {}));
            }
          })
      )
    ];
    return InputManager(title: "한도 변경하기", body: "변경할 내역", controller: controller, buttons: buttons);
  }
}
