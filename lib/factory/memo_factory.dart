class Memo {
  String data;
  int memoColor;
  bool important;

  Memo({required this.data, required this.memoColor, required this.important});

  factory Memo.fromJson(Map<String, dynamic> json) {
    String data = (json.containsKey("data"))?json['data']:"";
    int memoColor = (json.containsKey("color"))?json['color']:0;
    bool important = (json.containsKey("important"))?json['important']:false;
    return Memo(data: data, memoColor: memoColor, important: important);
  }

  getColor() => memoColor;
  getData() => data;
  isImportant() => important;
  toMap() => { "data" : data, "color": memoColor, "important": important };
}

class MemoMap {
  final Map<int, Memo> memo;
  MemoMap({required this.memo});

  factory MemoMap.fromJson(Map<String, dynamic> json) {
    Map<int, Memo> memos = {};
    for(var key in json.keys) {
      memos[int.parse(key)] = Memo.fromJson(json[key]);
    }
    return MemoMap(memo: memos);
  }

  hasKey(calendar) => memo.containsKey(calendar);
  get(calendar) => memo[calendar];
  set(calendar, newMemo) => memo[calendar] = newMemo;
  remove(calendar) => memo.remove(calendar);
  keys() => memo.keys;

  toMap() {
    Map<int, dynamic> map = {};
    for(var key in memo.keys) {
      map[key] = memo[key]!.toMap();
    }
    return map;
  }
}