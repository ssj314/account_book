import 'package:money_won/factory/memo_factory.dart';
import 'package:money_won/factory/salary_factory.dart';

import 'consumption_factory.dart';
import 'consumption_item_factory.dart';

class AccountBank {
  String name;
  int balance;
  int payday;
  ConsumptionMap consumption;
  ConsumptionItemMap items;
  Salary salary;
  MemoMap memo;

  AccountBank({
    required this.name,
    required this.balance,
    required this.payday,
    required this.salary,
    required this.memo,
    required this.consumption,
    required this.items
  });

  factory AccountBank.fromJson(Map<String, dynamic> json) {
    String name = json['name'] ?? "Bank";
    int balance = json['balance'] ?? 0;
    int payday = json['payday'] ?? 0;
    Salary salary = Salary.fromJson(json['salary'] ?? {});
    ConsumptionMap consumption = ConsumptionMap.fromJson(json['consumption'] ?? {});
    MemoMap memo = MemoMap.fromJson(json['memo'] ?? {});
    ConsumptionItemMap items = ConsumptionItemMap.fromJson(json['items'] ?? {});
    return AccountBank(
        name: name,
        balance: balance,
        payday: payday,
        salary: salary,
        memo: memo,
        consumption: consumption,
        items: items
    );
  }

  getName() => name;
  setName(value) => name = value;

  getConsumptionMap() => consumption;
  getItemMap() => items;
  getSalary() => salary;
  getMemoMap() => memo;

  getBalance() => balance;
  setBalance(value) => balance = value;

  getPayday() => payday;
  setPayday(value) => payday = value;

  toMap() {
    return {
      "name": name,
      "balance": balance,
      "payday": payday,
      "salary": salary.toMap(),
      "memo": memo.toMap(),
      "consumption": consumption.toMap(),
      "items": items.toMap()
    };
  }

}

class AccountBankMap {
  final List<AccountBank> items;
  AccountBankMap({required this.items});

  factory AccountBankMap.fromJson(List<dynamic> json) {
    List<AccountBank> items = [];
    for(var item in json) {
      items.add(AccountBank.fromJson(item));
    }
    return AccountBankMap(items: items);
  }

  hasKey(index) => index < items.length;
  getAccountBank(index) => items[index];
  remove(index) => items.removeAt(index);
  length() => items.length;
  add(AccountBank item) => items.add(item);

  toMap() {
    Map<String, dynamic> map = {};
    for(int index = 0; index < items.length; index++) {
      map["$index"] = items[index].toMap();
    }
    return map;
  }
}