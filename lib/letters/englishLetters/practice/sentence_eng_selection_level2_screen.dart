import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

import 'english_level2_quiz_all_screen.dart';
import 'english_level2_screen.dart';

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
      "emoji": "🏞️",
      "title": "A day at the park",
      "text":   "Today we went to the park. The sun was shining. We played on the swings and had fun.",
      "animation": "images/new_images/apples.json",
    },
    {
      "emoji":  "🎂",
      "title":  "My Birthday",
      "text":"It was my birthday last week. I got a big cake and balloons. My friends came to play with me.",
      "animation": "images/write.json",
    },
    
  {
    "emoji": "🐶",
    "title": "A Fun Morning with My Dog",
    "text": "My dog is very playful. He runs fast in the park every morning and loves chasing butterflies.",
    "animation": "images/Dog.json",
  },
  {
    "emoji": "🚗",
    "title": "Helping Dad Wash the Car",
    "text": "Every Saturday, Dad washes the car carefully. He uses a sponge, water, and soap to make it shine.",
    "animation": "images/car.json",
  },
  {
    "emoji": "📖",
    "title": "Reading Stories at the Library",
    "text": "We visit the library every week. I enjoy sitting with my friends and reading stories about space and animals.",
    "animation": "images/read.json",
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
        centerTitle: true,
        title: const Text(
          "English - Level 2",
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
            title: "Level 2 Quiz",
            jsonPath: "images/new_images/Quiz.json",
            onTap: () {
              _speak("Let's begin the quiz.");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EnglishLevel2WordQuizScreen()),
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
                    builder: (_) => EnglishLevel2Screen(sentence: sentence["text"]!),
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
