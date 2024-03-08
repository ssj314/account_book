class ConsumptionItem {
  String itemName;
  int itemCategory;
  int itemCost;

  ConsumptionItem({
    required this.itemCategory,
    required this.itemName,
    required this.itemCost
  });

  factory ConsumptionItem.fromJson(Map<String, dynamic> json) {
    int itemCategory = (json.containsKey("itemCategory"))?json['itemCategory']:0;
    String itemName = (json.containsKey("itemName"))?json['itemName']:"";
    int itemCost = (json.containsKey("itemCost"))?json['itemCost']:0;
    return ConsumptionItem(itemCategory: itemCategory, itemName: itemName, itemCost: itemCost);
  }

  getItemCategory() => itemCategory;
  getItemName() => itemName;
  getItemCost() => itemCost;
  toMap() => {
    "itemName": itemName,
    "itemCategory" : itemCategory,
    "itemCost": itemCost
  };
}

class ConsumptionItems {
  final List<ConsumptionItem> items;
  ConsumptionItems({required this.items});

  factory ConsumptionItems.fromJson(List<dynamic> json) {
    List<ConsumptionItem> items = [];
    for(var key in json) {
      if(key != null) {
        items.add(ConsumptionItem.fromJson(key));
      }
    }

    return ConsumptionItems(items: items);
  }

  get(index) => items[index];
  add(newItem) => items.add(newItem);
  update(index, item) => items[index] = item;
  remove(index) => items.removeAt(index);
  length() => items.length;

  toMap() {
    Map<int, dynamic> map = {};
    for (int index = 0; index < items.length; index++) {
      map[index + 1] = items[index].toMap();
    }
    return map;
  }
}

class ConsumptionItemMap {
  final Map<int, ConsumptionItems> items;
  ConsumptionItemMap({required this.items});

  factory ConsumptionItemMap.fromJson(Map<String, dynamic> json) {
    Map<int, ConsumptionItems> items = {};
    for(var key in json.keys) {
      if(json[key].isNotEmpty) {
        items[int.parse(key)] = ConsumptionItems.fromJson(json[key]);
      }
    }
    return ConsumptionItemMap(items: items);
  }

  hasKey(calendar) => items.containsKey(calendar);
  getItems(calendar) => items[calendar];
  set(calendar, newItem) => items[calendar] = newItem;
  remove(calendar) => items.remove(calendar);
  keys() => items.keys;

  toMap() {
    Map<int, dynamic> map = {};
    for(var key in items.keys) {
      map[key] = items[key]!.toMap();
    }
    return map;
  }
}