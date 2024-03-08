class User {
  String name;
  List colors;

  User({
    required this.name,
    required this.colors,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String name = json['name'] ?? "";
    List colors = json['colors'] ?? [];

    return User(
        name: name,
        colors: colors,
    );
  }

  getName() => name;
  setName(newName) => name = newName;

  toMap() {
    return {
      "name": name,
      "colors": colors,
    };
  }
}