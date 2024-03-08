import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import '/factory/user_factory.dart';
import '/fn/account_bank_manager.dart';

class UserManager {
  String uid;
  late User user;
  late BankManager bankManager;
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  late DatabaseReference userRef;

  UserManager(this.uid) {
    bankManager = BankManager(uid);
    userRef = ref.child("USER_DATA").child(uid);
  }

  create(user) async => await userRef.update(user.toMap());
  delete() async {
    await userRef.remove();
    await bankManager.remove();
  }

  init() async {
    var snapshot = await userRef.get();
    if (snapshot.value != null) user = User.fromJson(json.decode(jsonEncode(snapshot.value)));
    await bankManager.init();
  }

  getBank() => bankManager;
  getName() => user.getName();
  setName(name) async {
    user.setName(name);
    await userRef.child('name').set(user.getName());
  }

  getSavedColors() => user.colors;
  setSavedColors(colors) async => await userRef.child("colors").set(colors);
}