import 'package:intl/intl.dart';

class MoneyManager {

  final currency = NumberFormat("#,###", "en_US");
  final maxBalanceLimit = 10000000000;

  numberToKorean(int money) {
    if(money == 0) return "0원";
    var korean = "";
    int billion = 100000000;
    int million = 10000;
    if(money >= billion) {
      korean += "${(money/billion).floor()}억 ";
      money %= billion;
    }
    if(money >= million) {
      korean += "${(money/million).floor()}만 ";
      money %= million;
    }
    if(money > 0) {
      korean += "$money";
    }

    korean += "원";
    return korean;
  }

  koreanToNumber(String korean) {
    korean = korean.replaceAll("원", "");
    int money = 0;
    int billion = 100000000;
    int million = 10000;
    if(korean.contains("억")) {
      var tmp = korean.split("억");
      money += int.parse(tmp[0]) * billion;
      korean = (tmp[1] == ' ')?'0':tmp[1];
    }
    if(korean.contains("만")) {
      var tmp = korean.split("만");
      money += int.parse(tmp[0]) * million;
      korean = (tmp[1] == ' ')?'0':tmp[1];
    }
    money += int.parse(korean);
    return money;
  }
}