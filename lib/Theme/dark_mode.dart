import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: const Color.fromARGB(255, 113, 41, 195), // First gradient color
    primary: const Color(0xFF7E3FF2), // Second gradient color
    secondary: const Color.fromARGB(255, 196, 164, 255),
    inversePrimary: const Color.fromARGB(255, 3, 3, 3),
    inverseSurface: const Color.fromARGB(255, 196, 164, 255),
  ),
  textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: const Color.fromARGB(255, 0, 0, 0),
        displayColor: const Color.fromARGB(255, 0, 0, 0),
      ),
);

// Define the gradients separately
LinearGradient darkGradient = LinearGradient(
  colors: [Color.fromARGB(255, 110, 44, 185), Color(0xFF7E3FF2)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
