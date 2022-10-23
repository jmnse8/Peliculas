import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Colors.blueGrey;
  static Color secondary = Colors.blueGrey[100]!;

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    // Color primario
    primaryColor: Colors.lime,

    // AppBar Theme
    appBarTheme: const AppBarTheme(color: primary),
  );
}
