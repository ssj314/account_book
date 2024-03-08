class Salary {
  final Map<int, int> salary;
  Salary({required this.salary});

  factory Salary.fromJson(Map<String, dynamic> json) {
    var salary = <int, int>{};
    for (var key in json.keys) {
      salary[int.parse(key)] = json[key];
    }
    return Salary(salary: salary);
  }

  hasKey(calendar) => salary.containsKey(calendar);
  get(calendar) => salary[calendar];
  set(calendar, value) => salary[calendar] = value;
  remove(calendar) => salary.remove(calendar);
  keys() => salary.keys;

  toMap() {
    Map<int, dynamic> map = {};
    for(var key in salary.keys) {
      map[key] = salary[key];
    }
    return map;
  }
}