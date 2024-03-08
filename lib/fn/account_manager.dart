import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:money_won/factory/account_factory.dart';

class AccountManager {
  final authorized = 0;
  final unknownUser = 1;
  final wrongPassword = 2;
  final unknownException = 3;

  Account? account;
  late String uid;

  final key = "toyprojectsssang";
  final ref = FirebaseDatabase.instance.ref();
  late DatabaseReference accountRef;

  init(userName, email, password) {
    account = Account(email: email, userName: userName, password: _encrypt(password));
  }

  create() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: account!.getEmail(), password: account!.getPassword());
      await setUid(FirebaseAuth.instance.currentUser!.uid);
      await accountRef.update(account!.toMap());
    } catch(e) {
      throw Exception;
    }
  }

  delete() async {
    await FirebaseAuth.instance.currentUser!.delete();
    await accountRef.remove();
  }

  signOut() async => await FirebaseAuth.instance.signOut();

  isRegistered() async {
    var hasAccount = true;
    await accountRef.get().then((snapshot) {
      hasAccount = (snapshot.value == null) ? false : true;
    });
    return hasAccount;
  }

  get() async {
    if(account == null) {
      final snapshot = await accountRef.get();
      final jsonRes = json.decode(jsonEncode(snapshot.value));
      account = Account.fromJson(jsonRes);
    }
    return account;
  }

  _encrypt(String str) {
    final encryptKey = Key.fromUtf8(key);
    final iv = IV.fromLength(16);
    return Encrypter(AES(encryptKey)).encrypt(str, iv: iv).base64;
  }

  checkPassword(password) {
    return (account!.getPassword() == _encrypt(password));
  }

  setPassword(password) async {
    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
        email: account!.getEmail(),
        password: account!.getPassword()
    );
    await user!.reauthenticateWithCredential(cred).then((value) {
      user.updatePassword(_encrypt(password));
    });

    account!.setPassword(_encrypt(password));
    await accountRef.child("password").set(account!.getPassword());
  }

  getUid() => uid;

  setUid(uid) {
    this.uid = uid;
    accountRef = ref.child("ACCOUNT_DATA").child(this.uid);
  }

  getUserName() async {
    if(account == null) {
      await accountRef.get().then((snapshot) {
        if(snapshot.value != null) {
          final jsonRes = json.decode(jsonEncode(snapshot.value));
          account = AccountMap.fromJson(jsonRes).get(uid);
        }
      });
    }
    return account!.userName;
  }

  setUserName(userName) async {
    account!.setUserName(userName);
    await accountRef.child("userName").set(userName);
  }

  loginWithEmail(email, password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _encrypt(password),
      );
      setUid(FirebaseAuth.instance.currentUser!.uid);
      await get();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return unknownUser;
      } else if (e.code == 'wrong-password') {
        return wrongPassword;
      } else if(e.toString().contains('wrong-password')) {
        return wrongPassword;
      } else if(e.toString().contains('user-not-found')) {
        return unknownUser;
      } else {
        return unknownException;
      }
    }
    return authorized;
  }

  isDuplicatedEmail() async {
    var isDuplicated = false;
    await ref.child("ACCOUNT_DATA").get().then((snapshot) {
      if(snapshot.value != null) {
        final jsonRes = json.decode(jsonEncode(snapshot.value));
        final accounts = AccountMap.fromJson(jsonRes);
        for(var key in accounts.keys()) {
            if(account!.getEmail() == accounts.get(key).getEmail()) {
              isDuplicated = true;
              break;
            }
        }
      }
    });
    return isDuplicated;
  }

  getEmail() {
    return account!.getEmail();
  }
}