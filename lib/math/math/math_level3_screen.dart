import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';

import '../games/multi_step_equation_game.dart';
import '../games/reverse_equation_game.dart';
import '../games/word_story_math_game.dart';
import '../quiz/level3_quiz.dart';
import '../translations/locale_keys.dart';

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
    _speakIntro();
  }

  Future<void> _speak(String key) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.speak(tr(key));
  }

  Future<void> _speakIntro() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.speak(tr(LocaleKeys.math_level3_welcome));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFFFA726),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          tr(LocaleKeys.math_level3_title),
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
        childAspectRatio: 0.6,
        children: [
          _buildGameTile(
            context,
            titleKey: LocaleKeys.multi_step,
            jsonPath: "images/new_images/Multi-Step.json",
            onTap: () {
              _speak(LocaleKeys.tts_multi);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MultiStepEquationGame()));
            },
          ),
          _buildGameTile(
            context,
            titleKey: LocaleKeys.reverse_eq,
            jsonPath: "images/new_images/equation.json",
            onTap: () {
              _speak(LocaleKeys.tts_reverse);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ReverseEquationGame()));
            },
          ),
          _buildGameTile(
            context,
            titleKey: LocaleKeys.word_story,
            jsonPath: "images/new_images/think.json",
            onTap: () {
              _speak(LocaleKeys.tts_story);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WordStoryMathGame()));
            },
          ),
          _buildGameTile(
            context,
            titleKey: LocaleKeys.level3_quiz,
            jsonPath: "images/new_images/Quiz.json",
            onTap: () {
              _speak(LocaleKeys.tts_quiz3);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const Level3Quiz()));
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
