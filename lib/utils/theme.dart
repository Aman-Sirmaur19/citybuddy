import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF5F5F3)),
  colorScheme: const ColorScheme.light(
    background: Color(0xFFF5F5F3),
    primary: Colors.white,
    secondary: Colors.black,
    tertiary: Colors.grey,
    primaryContainer: Color(0xFFE5E5E4),
    secondaryContainer: Color(0xFFFFFFFF),
  ),
  iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.black))),
  useMaterial3: true,
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
  colorScheme: ColorScheme.dark(
    background: Colors.black,
    primary: Colors.grey.shade900,
    secondary: Colors.white,
    tertiary: Colors.grey.shade600,
    primaryContainer: const Color(0xFF1C1C1F),
    secondaryContainer: const Color(0xFF636366),
  ),
  iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.white))),
  useMaterial3: true,
);
