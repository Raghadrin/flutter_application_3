import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

import '../games/compare_quantities_game.dart';
import '../games/operation_sorting_game.dart';
import '../games/two_step_word_problem_game.dart';
import '../games/hard_equation_game.dart';
import '../quiz/level2_quiz.dart';

class MathLevel2Screen extends StatelessWidget {
  final FlutterTts tts = FlutterTts();

  MathLevel2Screen({super.key});

  void _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.2);
    await tts.speak(text);
  }

  void _speakIntro() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.speak("Welcome to Math Level 2. Let's compare, calculate, and solve word problems together!");
  }

  @override
  Widget build(BuildContext context) {
    _speakIntro();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text(
          "Math - Level 2",
          style: TextStyle(
            color: Colors.white,
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
        childAspectRatio: 0.9,
        children: [
          _buildGameTile(
            context,
            title: "Compare Quantities",
            jsonPath: "images/new_images/toys.json",
            onTap: () {
              _speak("Let's compare quantities.");
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CompareQuantitiesGame()));
            },
          ),
          _buildGameTile(
            context,
            title: "Choose Operation",
            jsonPath: "images/new_images/operation.json",
            onTap: () {
              _speak("Choose the correct operation.");
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OperationSortingGame()));
            },
          ),
          _buildGameTile(
            context,
            title: "Word Problem",
            jsonPath: "images/new_images/think.json",
            onTap: () {
              _speak("Solve the story problem.");
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TwoStepWordProblemGame()));
            },
          ),
          _buildGameTile(
            context,
            title: "Hard Equations",
            jsonPath: "images/new_images/equation.json",
            onTap: () {
              _speak("Try solving hard equations.");
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HardEquationGame()));
            },
          ),
          _buildGameTile(
            context,
            title: "Level 2 Quiz",
            jsonPath: "images/new_images/Quiz.json",
            onTap: () {
              _speak("Let’s begin the quiz for level 2.");
              Navigator.push(context, MaterialPageRoute(builder: (_) => const Level2QuizScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameTile(BuildContext context, {
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