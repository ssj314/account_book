import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '/factory/account_factory.dart';
import '/factory/simple_account_factory.dart';

class SimpleAccountManager {
  SimpleAccountMap? account;
  String? userName;
  String? uid;

  final ref = FirebaseDatabase.instance.ref();
  late DatabaseReference accountRef = ref.child("SIMPLE_ACCOUNT_DATA");

  init({required uid, required userName}) {
    this.uid = uid;
    this.userName = userName;
  }

  create() async {
    try {
      await accountRef.child(uid!).set(userName!);
    } catch(e) {
      throw Exception;
    }
  }

  get() async {
    if(account == null) {
      final snapshot = await accountRef.get();
      final jsonRes = json.decode(jsonEncode(snapshot.value));
      account = SimpleAccountMap.fromJson(jsonRes);
    }
    return account;
  }

  isInitial() async {
    var isInitial = true;
    await ref.child("SIMPLE_ACCOUNT_DATA").get().then((snapshot) {
      if(snapshot.value != null) {
        final jsonRes = json.decode(jsonEncode(snapshot.value));
        final accounts = SimpleAccountMap.fromJson(jsonRes);
        for(var key in accounts.keys()) {
          if(uid == key) {
            isInitial = false;
            break;
          }
        }
      }
    });
    return isInitial;
  }

  signOut() async => await FirebaseAuth.instance.signOut();
  delete() async {
    await FirebaseAuth.instance.currentUser!.delete();
    await accountRef.child(uid!).remove();
  }

  getUserName() async {
    if(userName == null) {
      await accountRef.child(uid!).get().then((snapshot) {
        if(snapshot.value != null) {
          userName = snapshot.value.toString();
        }
      });
    }
    return userName;
  }

  setUserName(userName) async {
    account!.set(uid, userName);
    await accountRef.child(uid!).set(userName);
  }

  getUid() => uid;
  setUid(uid) => this.uid = uid;
}