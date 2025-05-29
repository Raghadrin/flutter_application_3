import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';
import '../games/number_recognition_game.dart';
import '../games/number_quantity_matching_game.dart';
import '../games/number_tracing_game.dart';
import '../games/complete_equation_game.dart';
import '../quiz/level1_quiz.dart';
import '../translations/locale_keys.dart';

class MathLevel1Screen extends StatelessWidget {
  final FlutterTts tts = FlutterTts();

  MathLevel1Screen({super.key});

  void _speak(BuildContext context, String textKey) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.speak(tr(textKey));
  }

  @override
  Widget build(BuildContext context) {
    _speak(context, LocaleKeys.math_level1_welcome);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          tr(LocaleKeys.math_level1_title),
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
        childAspectRatio: 0.59,
        children: [
          _buildGameTile(
            context,
            titleKey: LocaleKeys.recognize_number,
            jsonPath: "images/new_images/number_3.json",
            onTap: () {
              _speak(context, LocaleKeys.tts_recognize);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NumberRecognitionGame()));
            },
          ),
          _buildGameTile(
            context,
            titleKey: LocaleKeys.match_quantity,
            jsonPath: "images/new_images/apples.json",
            onTap: () {
              _speak(context, LocaleKeys.tts_match);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NumberQuantityMatchingGame()));
            },
          ),
          _buildGameTile(
            context,
            titleKey: LocaleKeys.trace_number,
            jsonPath: "images/new_images/tracing.json",
            onTap: () {
              _speak(context, LocaleKeys.tts_trace);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NumberTracingGame()));
            },
          ),
          _buildGameTile(
            context,
            titleKey: LocaleKeys.complete_equation,
            jsonPath: "images/new_images/equation.json",
            onTap: () {
              _speak(context, LocaleKeys.tts_equation);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CompleteEquationGame()));
            },
          ),
          _buildGameTile(
            context,
            titleKey: LocaleKeys.level1_quiz,
            jsonPath: "images/new_images/Quiz.json",
            onTap: () {
              _speak(context, LocaleKeys.tts_quiz);
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
