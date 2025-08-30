import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color.fromARGB(255, 63, 81, 181),
  colorScheme: const ColorScheme.light(
    primary: Colors.indigo,
    secondary: Colors.amber,
  ),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.indigo,
    elevation: 0,
  ),
  drawerTheme: const DrawerThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    elevation: 0,
    backgroundColor: Colors.white,
  ),
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.deepOrange,
  colorScheme: const ColorScheme.dark(
    primary: Colors.deepOrange,
    secondary: Colors.tealAccent,
  ),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.deepOrange,
    elevation: 0,
  ),
  drawerTheme: const DrawerThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    elevation: 0,
    backgroundColor: Colors.black,
  ),
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
);
