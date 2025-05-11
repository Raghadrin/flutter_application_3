import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../games/complete_equation_game.dart' as complete;
import '../games/operation_choice_game.dart' as operation;
import '../games/arrange_equation_game.dart';

import '../quiz/level1_quiz.dart';

class MathLevel1Screen extends StatelessWidget {
  final FlutterTts tts = FlutterTts();

  MathLevel1Screen({super.key});

  void _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setPitch(1.0);
    await tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    _speak("Welcome to Level 1. Let's learn basic math equations!");
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: const Text(
          "Math - Level 1",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Image.asset("images/subject_fox.PNG", height: 140),
          const SizedBox(height: 20),
          _buildGameButton(context, "Complete the Equation", () {
            _speak("Let's complete the equation.");
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => complete.CompleteEquationGame()));
          }),
          _buildGameButton(context, "Choose the Correct Operation", () {
            _speak("Which math operation fits this equation?");
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => operation.OperationChoiceGame()));
          }),
          _buildGameButton(context, "Arrange the Equation", () {
            _speak("Arrange the numbers and symbols to build a correct equation.");
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ArrangeEquationGame()));
          }),
          const Divider(height: 40),
          _buildGameButton(context, "Test What You Learned", () {
            _speak("Let's test what you learned in Level 1.");
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const Level1Quiz()));
          }),
        ],
      ),
    );
  }

  Widget _buildGameButton(BuildContext context, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Color(0xFFFBD1B2), Color(0xFFFEE5D3)],
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
