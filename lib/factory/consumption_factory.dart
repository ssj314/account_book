class Consumption {
  int limit;
  int expenditure;

  Consumption({required this.limit, required this.expenditure});

  factory Consumption.fromJson(Map<String, dynamic> json) {
    var limit = (json.containsKey("limit"))?json['limit']:0;
    var expenditure = (json.containsKey("expenditure"))?json['expenditure']:0;
    return Consumption(limit: limit, expenditure: expenditure);
  }

  toMap() => { "limit" : limit, "expenditure": expenditure };
  getLimit() => limit;
  setLimit(value) => limit = value;

  getExpenditure() => expenditure;
  setExpenditure(value) => expenditure = value;
}

class ConsumptionMap {
  final Map<int, Consumption> consumption;
  ConsumptionMap({required this.consumption});

  factory ConsumptionMap.fromJson(Map<String, dynamic> json) {
    var consumptions = <int, Consumption>{};
    for (var key in json.keys) {
      consumptions[int.parse(key)] = Consumption.fromJson(json[key]);
    }
    return ConsumptionMap(consumption: consumptions);
  }

  hasKey(calendar) => consumption.containsKey(calendar);
  get(calendar) => consumption[calendar];

  set(int calendar, consumption) {
    Consumption newConsumption = consumption;
    this.consumption[calendar] = newConsumption;
  }

  keys() => consumption.keys;

  toMap() {
    Map<int, dynamic> map = {};
    for(var key in consumption.keys) {
      map[key] = consumption[key]!.toMap();
    }
    return map;
  }
}