import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get currentTheme {
    return _isDarkMode
        ? ThemeData.dark().copyWith(
      primaryColor: Colors.blueAccent,
      scaffoldBackgroundColor: Colors.black,
    )
        : ThemeData.light().copyWith(
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
    );
  }
}