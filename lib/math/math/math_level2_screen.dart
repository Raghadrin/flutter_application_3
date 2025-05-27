import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';

import '../games/compare_quantities_game.dart';
import '../games/operation_sorting_game.dart';
import '../games/two_step_word_problem_game.dart';
import '../games/hard_equation_game.dart';
import '../quiz/level2_quiz.dart';
import '../translations/locale_keys.dart';

class MathLevel2Screen extends StatelessWidget {
  final FlutterTts tts = FlutterTts();

  MathLevel2Screen({super.key});

  void _speak(BuildContext context, String key) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.2);
    await tts.speak(tr(key));
  }

  void _speakIntro(BuildContext context) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.speak(tr(LocaleKeys.math_level2_welcome));
  }

  @override
  Widget build(BuildContext context) {
    _speakIntro(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFFFA726),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          tr(LocaleKeys.math_level2_title),
          style: const TextStyle(
            color: Colors.black,
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
        childAspectRatio: 0.7,
        children: [
          _buildGameTile(
            context,
            titleKey: LocaleKeys.compare_quantities,
            jsonPath: "images/new_images/toys.json",
            onTap: () {
              _speak(context, LocaleKeys.tts_compare);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CompareQuantitiesGame()));
            },
          ),
          _buildGameTile(
            context,
            titleKey: LocaleKeys.choose_operation,
            jsonPath: "images/new_images/operation.json",
            onTap: () {
              _speak(context, LocaleKeys.tts_choose);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OperationSortingGame()));
            },
          ),
          _buildGameTile(
            context,
            titleKey: LocaleKeys.word_problem,
            jsonPath: "images/new_images/think.json",
            onTap: () {
              _speak(context, LocaleKeys.tts_word);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TwoStepWordProblemGame()));
            },
          ),
          _buildGameTile(
            context,
            titleKey: LocaleKeys.hard_equations,
            jsonPath: "images/new_images/equation.json",
            onTap: () {
              _speak(context, LocaleKeys.tts_hard);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HardEquationGame()));
            },
          ),
          _buildGameTile(
            context,
            titleKey: LocaleKeys.level2_quiz,
            jsonPath: "images/new_images/Quiz.json",
            onTap: () {
              _speak(context, LocaleKeys.tts_quiz2);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const Level2QuizScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameTile(
    BuildContext context, {
    required String titleKey,
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
              tr(titleKey),
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
