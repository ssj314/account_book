import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import '/factory/account_bank_factory.dart';
import '/factory/consumption_factory.dart';
import '/factory/consumption_item_factory.dart';
import '/factory/memo_factory.dart';
import '/factory/salary_factory.dart';

class BankManager {
  String uid;
  late AccountBankMap bankMap;
  late AccountBank bank;
  int bankIndex = 0;

  DatabaseReference ref = FirebaseDatabase.instance.ref();
  late DatabaseReference userRef;
  late DatabaseReference bankRef;

  BankManager(this.uid) {
    userRef = ref.child("ACCOUNT_BANK").child(uid);
    bankRef = userRef.child("$bankIndex");
  }

  setIndex(index) {
    bankIndex = index;
    bankRef = userRef.child("$bankIndex");
    bank = bankMap.getAccountBank(index);
  }

  getIndex() => bankIndex;

  getList() {
    List<String> items = [];
    for(var i = 0; i < bankMap.length(); i++) {
      items.add(bankMap.getAccountBank(i).getName());
    }
    return items;
  }

  init() async {
    var snapshot = await userRef.get();
    if (snapshot.value != null) {
      final jsonRes = json.decode(jsonEncode(snapshot.value));
      bankMap = AccountBankMap.fromJson(jsonRes);
      bank = bankMap.getAccountBank(bankIndex);
    } else {
      bankMap = AccountBankMap(items: []);
      create("가계부");
    }
  }

  create(String bankName) async {
    bank = AccountBank(
        name: bankName,
        balance: 0,
        payday: 1,
        salary: Salary(salary: {}),
        memo: MemoMap(memo: {}),
        consumption: ConsumptionMap(consumption: {}),
        items: ConsumptionItemMap(items: {})
    );
    bankMap.add(bank);
    await userRef.update(bankMap.toMap());
  }

  delete(int index) async {
      bankMap.remove(index);
      await userRef.set(bankMap.toMap());
  }

  remove() async => await userRef.remove();

  rename(String newName, int index) async {
    setIndex(index);
    bank.setName(newName);
    await bankRef.child("name").set(newName);
  }

  addExp(calendar, value) async {
    ConsumptionMap cMap = bank.getConsumptionMap();
    if(!cMap.hasKey(calendar)) cMap.set(calendar, Consumption(limit: -1, expenditure: 0));
    final expenditure = bank.getConsumptionMap().get(calendar).getExpenditure();
    bank.getConsumptionMap().get(calendar).setExpenditure(expenditure + value);
    await bankRef.child("consumption/$calendar/").update(bank.getConsumptionMap().get(calendar).toMap());
  }

  getExp(calendar) {
    ConsumptionMap cMap = bank.getConsumptionMap();
    if(cMap.hasKey(calendar)){
      return cMap.get(calendar).getExpenditure();
    } else {
      return 0;
    }
  }

  getPayday() => bank.getPayday();

  setPayday(value) async {
    bank.setPayday(value);
    await bankRef.child("payday").set(value);
  }

  setLimit(calendar, value) async {
    ConsumptionMap map = bank.getConsumptionMap();
    if(!map.hasKey(calendar)) map.set(calendar, Consumption(limit: -1, expenditure: 0));
    bank.getConsumptionMap().get(calendar).setLimit(value);
    await bankRef.child("consumption/$calendar/").update(bank.consumption.get(calendar).toMap());
  }

  getLimit(calendar) {
    ConsumptionMap map = bank.getConsumptionMap();
    return map.hasKey(calendar)?map.get(calendar).getLimit():-1;
  }

  addBalance(value) async {
    final balance = bank.getBalance();
    bank.setBalance(balance + value);
    if(bank.getBalance() < 0) bank.setBalance(0);
    await bankRef.child('balance').set(bank.getBalance());
  }

  getBalance() => bank.getBalance();

  getSalary(calendar) {
    return bank.getSalary().hasKey(calendar)?bank.getSalary().get(calendar):0;
  }

  setSalary(calendar, value) async {
    if(bank.getSalary().get(calendar) != value) {
      bank.getSalary().set(calendar, value);
      await bankRef.child('salary/$calendar').set(value);
    }
  }

  getTotalExp(start, end) {
    var total = 0;
    for(var key in bank.getConsumptionMap().keys())  {
      if(start <= key && key <= end) {
          final cost = bank.getConsumptionMap().get(key).getExpenditure();
          total += cost as int;
        }
    }
    return total;
  }

  getTotalLimit(start, end) {
    int total = 0;
    bool flag = false;

    for(var key in bank.getConsumptionMap().keys())  {
      if(start <= key && key <= end) {
        int cost = bank.getConsumptionMap().get(key).getLimit();
        if(cost >= 0) {
          total += cost;
          if(!flag) flag = true;
        }
      }
    }
    return (flag)?total:-1;
  }

  hasMemo(calendar) => bank.getMemoMap().hasKey(calendar);
  getMemo(calendar) {
    final memo = bank.getMemoMap().get(calendar);
    return Memo(memoColor: memo.memoColor, data: memo.data, important: memo.important);
  }

  setMemo(calendar, memo) async {
    bank.getMemoMap().set(calendar, memo);
    await bankRef.child("memo/$calendar/").update(memo.toMap());
  }

  removeMemo(calendar) async {
    if(bank.getMemoMap().hasKey(calendar)) {
      bank.getMemoMap().remove(calendar);
      await bankRef.child("memo/$calendar/").remove();
      return true;
    }
  }
  
  getItem(calendar, index) {
    ConsumptionItems items = bank.getItemMap().getItems(calendar);
    if(items.length() < index) {
      return null;
    } else {
      ConsumptionItem item = items.get(index);
      return ConsumptionItem(
          itemCategory: item.itemCategory,
          itemCost: item.itemCost,
          itemName: item.itemName
      );
    }
  }

  getItemCount(calendar) {
    final items = bank.getItemMap();
    if(items.hasKey(calendar)) {
      return items.getItems(calendar).length();
    } else {
      return 0;
    }
  }

  addItem(calendar, ConsumptionItem item) async {
    if(bank.getItemMap().hasKey(calendar)) {
      ConsumptionItems items = bank.getItemMap().getItems(calendar);
      items.add(item);
      int lastIndex = items.length();
      await bankRef.child("items/$calendar/$lastIndex").set(item.toMap());
    } else {
      ConsumptionItems items = ConsumptionItems(items: [item]);
      bank.getItemMap().set(calendar, items);
      await bankRef.child("items/$calendar/").set(items.toMap());
    }
  }

  editItem(calendar, index, item) async {
    ConsumptionItems items = bank.getItemMap().getItems(calendar);
    items.update(index, item);
    await bankRef.child("items/$calendar/$index").set(item.toMap());
  }

  removeItem(calendar, index) async {
    ConsumptionItems items = bank.getItemMap().getItems(calendar);
    if(items.length() < index) {
      return false;
    } else {
      items.remove(index);
      await bankRef.child("items/$calendar/").set(items.toMap());
      return true;
    }
  }

  syncBank(int calendar) async {
    int cost = 0;
    for(int i = 0; i < getItemCount(calendar); i++) {
      ConsumptionItem item = getItem(calendar, i);
      cost += item.itemCost;
    }

    int exp = getExp(calendar);
    if(cost != exp) {
        int sub = cost - exp;
        addExp(calendar, sub);
        addBalance(sub);
    }
  }
}