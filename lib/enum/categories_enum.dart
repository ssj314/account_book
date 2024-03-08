import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum Category {
  food(idx: 0, label: "식비", icon: Icons.restaurant),
  edu(idx: 1, label: "교육", icon: Icons.book_rounded),
  conv(idx: 2, label: "편의점", icon: Icons.store_mall_directory_rounded),
  cafe(idx: 3, label: "카페", icon: Icons.emoji_food_beverage_rounded),
  drink(idx: 4, label: "술", icon: Icons.sports_bar_rounded),
  shop(idx: 5, label: "쇼핑", icon: CupertinoIcons.shopping_cart),
  hobby(idx: 6, label: "취미", icon: Icons.sports_tennis_rounded),
  health(idx: 7, label: "건강", icon: CupertinoIcons.heart_fill),
  traffic(idx: 8, label: "교통", icon: CupertinoIcons.bus),
  subs(idx: 9, label: "구독", icon: CupertinoIcons.play),
  etc(idx: 10, label: "기타", icon: CupertinoIcons.ellipsis);

  final int idx;
  final String label;
  final IconData icon;
  const Category({
    required this.idx,
    required this.label,
    required this.icon,
  });
}