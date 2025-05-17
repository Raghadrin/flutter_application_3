
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

import '../games/multi_step_equation_game.dart';
import '../games/reverse_equation_game.dart';
import '../games/word_story_math_game.dart';
import '../quiz/level3_quiz.dart';

class MathLevel3Screen extends StatefulWidget {
  const MathLevel3Screen({super.key});

  @override
  State<MathLevel3Screen> createState() => _MathLevel3ScreenState();
}

class _MathLevel3ScreenState extends State<MathLevel3Screen> {
  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speak("Welcome to Math Level 3. Let's solve multi-step equations, reverse operations, and word story problems together.");
  }

  Future<void> _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45);
    await tts.speak(text);
  }

  void _onTileTap(String title, Widget screen) {
    _speak(title);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text(
          "Math - Level 3",
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
          _buildGameTile("Multi-Step Equations", "images/new_images/Multi-Step.json", () {
            _onTileTap("Multi-Step Equations", const MultiStepEquationGame());
          }),
          _buildGameTile("Reverse Equation", "images/new_images/equation.json", () {
            _onTileTap("Reverse Equation", const ReverseEquationGame());
          }),
          _buildGameTile("Word Story Problem", "images/new_images/think.json", () {
            _onTileTap("Word Story Problem", const WordStoryMathGame());
          }),
          _buildGameTile("Level 3 Quiz", "images/new_images/Quiz.json", () {
            _onTileTap("Level 3 Quiz", const Level3Quiz());
          }),
        ],
      ),
    );
  }

  Widget _buildGameTile(String title, String jsonPath, VoidCallback onTap) {
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
