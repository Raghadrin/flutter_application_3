import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: const Color(0xFFD7FBE0), // First gradient color
    primary: const Color(0xFFAFFFD7), // Second gradient color
    secondary: const Color.fromARGB(255, 254, 175, 110),
    inversePrimary: const Color.fromARGB(255, 255, 164, 103),
    inverseSurface: const Color.fromARGB(255, 254, 175, 110),
  ),
  textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
);
LinearGradient lightGradient = LinearGradient(
  colors: [Color(0xFFD7FBE0), Color(0xFFAFFFD7)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
