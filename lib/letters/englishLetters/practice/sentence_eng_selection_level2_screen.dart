import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

import 'english_level2_screen.dart';
import 'english_level2_quiz_all_screen.dart';

class EnglishLevel2HomeScreen extends StatelessWidget {
  final FlutterTts tts = FlutterTts();

  EnglishLevel2HomeScreen({super.key});

  void _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.speak(text);
  }

  final List<Map<String, String>> sentences = [
    {
      "emoji": "🏫",
      "title": "School Activity",
      "text": "The hardworking boy goes to school every morning with energy.",
      "animation": "assets/animations/school.json",
    },
    {
      "emoji": "🩺",
      "title": "Treating Patients",
      "text": "The doctor treats patients at the hospital using precise tools.",
      "animation": "assets/animations/doctor.json",
    },
    {
      "emoji": "🚦",
      "title": "Obeying the Law",
      "text": "The red car stopped at the red light in respect of the law.",
      "animation": "assets/animations/traffic.json",
    },
    {
      "emoji": "📚",
      "title": "Daily Reading",
      "text": "I read a useful book in the library every day after school.",
      "animation": "assets/animations/read.json",
    },
    {
      "emoji": "👩‍🍳",
      "title": "Healthy Cooking",
      "text": "Mom prepares delicious food with healthy ingredients for the family.",
      "animation": "assets/animations/cook.json",
    },
  ];

  @override
  Widget build(BuildContext context) {
    _speak("Welcome to Level 2. Please choose a sentence to start learning.");

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: const Text(
          "English - Level 2",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
        children: [
          _buildTile(
            context,
            title: "Level 2 Quiz",
            jsonPath: "assets/animations/quiz.json",
            onTap: () {
              _speak("Let's begin the quiz.");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EnglishLevel2WordQuizScreen(),
                ),
              );
            },
          ),
          ...sentences.map((sentence) {
            return _buildTile(
              context,
              title: sentence["title"]!,
              jsonPath: sentence["animation"]!,
              onTap: () {
                _speak("You selected: ${sentence["title"]}");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EnglishLevel2Screen(
                      sentence: sentence["text"]!,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTile(
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
          border: Border.all(color: Colors.orange, width: 3),
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
