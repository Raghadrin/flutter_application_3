import 'package:flutter/material.dart';

class AppTheme {
  static const Color backgroundColor = Color(0xFFFFF6ED); // Soft cream background
  static const Color buttonColor = Color(0xFFFFCC80); // Light orange button
  static const Color correctColor = Colors.green;
  static const Color wrongColor = Colors.red;
  static const Color appBarColor = Color(0xFFFFA726); // Deeper orange for app bars

  static const TextStyle questionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle optionStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static const TextStyle feedbackStyleCorrect = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: correctColor,
  );

  static const TextStyle feedbackStyleWrong = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: wrongColor,
  );

  static const TextStyle counterStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black54,
  );

  static const TextStyle hintStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );

  static final BoxDecoration inputBoxDecoration = BoxDecoration(
    color: Color(0xFFFFE0B2),
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 4)),
    ],
  );

  static ButtonStyle elevatedButtonStyle(Color bgColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
