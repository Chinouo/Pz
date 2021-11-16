import 'package:flutter/material.dart';

class CustomTheme extends ChangeNotifier {
  bool isDark = false;

  void change() {
    isDark = !isDark;
  }
}
