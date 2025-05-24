import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

import 'english_level1_quiz_all.dart';
import 'english_level1_screen.dart';

class EnglishLevel1HomeScreen extends StatelessWidget {
  final FlutterTts tts = FlutterTts();

  EnglishLevel1HomeScreen({super.key});

  void _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.speak(text);
  }

  final List<Map<String, String>> sentences = [
    {
      "emoji": "🌞",
      "title": "Sunrise",
      "text": "The sun rises every morning",
      "animation": "images/sun.json",
    },
    {
      "emoji": "✍️",
      "title": "Homework",
      "text": "The boy is doing his homework",
      "animation": "images/write.json",
    },
    {
      "emoji": "👩‍🍳",
      "title": "Cooking",
      "text": "Mom is cooking food",
      "animation": "images/cook.json",
    },
    {
      "emoji": "🚗",
      "title": "Road",
      "text": "The car drives on the road",
      "animation": "images/car.json",
    },
    {
      "emoji": "📖",
      "title": "Reading",
      "text": "I love reading books",
      "animation": "images/read.json",
    },
  ];

  @override
  Widget build(BuildContext context) {
    _speak("Welcome to Level 1. Please choose a sentence to start learning.");

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "English - Level 1",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
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
            title: "Level 1 Quiz",
            jsonPath: "images/new_images/Quiz.json",
            onTap: () {
              _speak("Let's begin the quiz.");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EnglishLetterQuizScreen()),
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
                    builder: (_) => EnglishLevel1Screen(sentence: sentence["text"]!),
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
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
