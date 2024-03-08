import 'package:flutter/material.dart';

class ColorPalette {
  static bool isDarkMode = true;

  of(context) {
    isDarkMode = (MediaQuery.of(context).platformBrightness == Brightness.dark);
    return ColorPalette();
  }

  // Container Colors
  final background = (isDarkMode)? const Color(0xff17171a) : const Color(0xffeff1f3);
  final primary = (isDarkMode)? const Color(0xff1d1d21) : const Color(0xfffcfcfc);
  final secondary = (isDarkMode)? const Color(0xff3e3e46):const Color(0xffe2e5e8);
  final accent = (isDarkMode)? const Color(0xff636366):const Color(0xffaeaeb2);
  final complementary = (isDarkMode)? const Color(0xffeff1f3) : const Color(
      0xff17171a);
  final complementary60 = (isDarkMode)? const Color(0x99eff1f3) : const Color(
      0x9917171a);
  final translucent = const Color(0xffffffff);
  // Text Colors
  final textColor = (isDarkMode)? const Color(0xffffffff): const Color(0xff000000);
  late final textAccent = systemBlue;
  late final textAlert = systemRed;

  // Material Colors
  late final indicatorColor = systemBlue;
  late final itemActiveColor = (isDarkMode)?systemWhite:systemBlack;
  late final buttonBgColor = systemBlue;
  late final buttonFgColor = systemCyan;
  late final buttonTextColor = systemWhite;
  late final defaultMemoColor = systemYellow;

  // System Colors
  final systemPink = (isDarkMode)?const Color(0xffff375f):const Color(
      0xffff2d55);
  final systemRed = (isDarkMode)?const Color(0xffff453a):const Color(0xffff3b30);
  final systemCyan = (isDarkMode)?const Color(0xff64d2ff):const Color(0xff32ade6);
  final systemTeal = (isDarkMode)?const Color(0xff6ac4dc):const Color(
      0xff59adc4);
  final systemBlue = (isDarkMode)?const Color(0xff0a84ff):const Color(0xff007aff);
  final systemYellow = (isDarkMode)?const Color(0xfffff44f):const Color(0xffffcc00);
  final systemIndigo = (isDarkMode)?const Color(0xff5e5ce6):const Color(0xff5856d6);
  final systemBlack = const Color(0xff000000);
  final systemBlack80 = const Color(0xcc000000);
  final systemWhite = const Color(0xffffffff);
  final systemWhite80 = const Color(0xccffffff);
  final systemGrey = const Color(0xff464646);
  final systemGreen = (isDarkMode)?const Color(0xff30d158) : const Color(0xff34c759);
}