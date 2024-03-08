class SimpleAccountMap {
  Map<String, String> accountMap;
  SimpleAccountMap({ required this.accountMap });

  factory SimpleAccountMap.fromJson(Map<String, dynamic> json) {
    Map<String, String> map = {};
    for(var key in json.keys) {
      map[key] = json[key];
    }
    return SimpleAccountMap(accountMap: map);
  }

  hasKey(uid) => accountMap.containsKey(uid);
  get(uid) => accountMap[uid];
  set(uid, value) => accountMap[uid] = value;
  keys() => accountMap.keys;
  toMap() => accountMap;
}