import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

import '../games/number_recognition_game.dart';
import '../games/number_quantity_matching_game.dart';
import '../games/number_tracing_game.dart';
import '../games/complete_equation_game.dart';
import '../quiz/level1_quiz.dart';

class MathLevel1Screen extends StatelessWidget {
  final FlutterTts tts = FlutterTts();

  MathLevel1Screen({super.key});

  void _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    _speak("Welcome to Level 1. Let's explore numbers in fun ways!");

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        elevation: 0,
        leading: BackButton(color: const Color.fromARGB(255, 0, 0, 0)),
        title: const Text(
          "Math - Level 1",
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.59,
        children: [
          _buildGameTile(
            context,
            title: "Recognize Number",
            jsonPath: "images/new_images/number_3.json",
            onTap: () {
              _speak("Let's recognize numbers.");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NumberRecognitionGame()));
            },
          ),
          _buildGameTile(
            context,
            title: "Match to Quantity",
            jsonPath: "images/new_images/apples.json",
            onTap: () {
              _speak("Match the number to the correct group.");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NumberQuantityMatchingGame()));
            },
          ),
          _buildGameTile(
            context,
            title: "Trace the Number",
            jsonPath: "images/new_images/tracing.json",
            onTap: () {
              _speak("Trace the number with your finger.");
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NumberTracingGame()));
            },
          ),
          _buildGameTile(
            context,
            title: "Complete Equation",
            jsonPath: "images/new_images/equation.json",
            onTap: () {
              _speak("Let's complete the equation.");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CompleteEquationGame()));
            },
          ),
          _buildGameTile(
            context,
            title: "Level 1 Quiz",
            jsonPath: "images/new_images/Quiz.json",
            onTap: () {
              _speak("Let's test what you learned.");
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const Level1Quiz()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameTile(
    BuildContext context, {
    required String title,
    required String jsonPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.deepOrange, width: 3),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(jsonPath, height: 100),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepOrange,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
