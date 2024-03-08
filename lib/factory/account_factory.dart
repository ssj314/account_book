class Account {
  String email;
  String userName;
  String password;
  Account({required this.email, required this.userName, required this.password});

  factory Account.fromJson(Map<String, dynamic> json) {
    var email = (json.containsKey("email"))?json['email']:null;
    var userName = (json.containsKey("userName"))?json['userName']:null;
    var password = (json.containsKey("userName"))?json['password']:null;
    return Account(email: email, userName: userName, password: password);
  }

  getEmail() => email;
  getUserName() => userName;
  setUserName(newUserName) => userName = newUserName;
  getPassword() => password;
  setPassword(newPassword) => password = newPassword;
  toMap() => {"userName": userName, "email": email, "password": password};
}

class AccountMap {
  Map<String, Account> accountMap;
  AccountMap({ required this.accountMap });

  factory AccountMap.fromJson(Map<String, dynamic> json) {
    Map<String, Account> map = {};
    for(var key in json.keys) {
      map[key] = Account.fromJson(json[key]);
    }
    return AccountMap(accountMap: map);
  }

  hasKey(uid) => accountMap.containsKey(uid);
  get(uid) => accountMap[uid];
  keys() => accountMap.keys;
  toMap() => accountMap;
}