import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      backgroundColor: const Color(0xff252525),
      accentColor: Colors.grey,
      snackBarTheme: SnackBarThemeData(
        actionTextColor: Colors.blue
      ),
      scaffoldBackgroundColor: const Color(0xff252525),
      appBarTheme: AppBarTheme(
        color: const Color(0xff252525),
        elevation: 0
      )
    ),
  ));
}

