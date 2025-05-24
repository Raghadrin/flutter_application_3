import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

import 'english_level3_screen.dart';
import 'english_level3_quiz_all_screen.dart';

class EnglishLevel3HomeScreen extends StatelessWidget {
  final FlutterTts tts = FlutterTts();

  EnglishLevel3HomeScreen({super.key});

  void _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.speak(text);
  }

  final List<Map<String, dynamic>> stories = [
    {
      'emoji': '🌳',
      'title': 'A Day in the Park',
      'paragraph':
          'On a sunny morning, Sami went to the park with his father. He played with his friends a lot, then they sat together to eat and watch birds flying in the sky.',
      'questions': [
        "What is the title of the story?",
        "Who went to the park?",
        "What did Sami do with his friends?",
        "What did they see in the sky?"
      ],
      'answers': [
        "A Day in the Park",
        "Sami and his father",
        "Played a lot",
        "Birds"
      ],
      'animation': 'assets/animations/park.json',
    },
    {
      'emoji': '🌧️',
      'title': 'Rainy Games',
      'paragraph':
          'In the winter, it rains and the ground gets wet. Children love wearing coats and boots, playing in water and making small boats.',
      'questions': [
        "In which season did the story happen?",
        "What happens to the ground?",
        "What do the children play with?",
        "What do they wear?"
      ],
      'answers': [
        "Winter",
        "It gets wet",
        "Small boats",
        "Coats and boots"
      ],
      'animation': 'assets/animations/rain.json',
    },
    {
      'emoji': '📖',
      'title': 'Bedtime Story',
      'paragraph':
          'Sarah loves reading stories before bedtime. Every night, she chooses a fun story to read with her mom, then closes her eyes and dreams of beautiful places.',
      'questions': [
        "Who loves reading stories?",
        "When does she read the story?",
        "Who reads with her?",
        "What does she dream of?"
      ],
      'answers': [
        "Sarah",
        "Before bedtime",
        "Her mom",
        "Beautiful places"
      ],
      'animation': 'assets/animations/book.json',
    },
    {
      'emoji': '🏫',
      'title': 'At School',
      'paragraph':
          'At school, students learn reading, writing, and math. They love the teacher because he helps them understand and always encourages them to work hard.',
      'questions': [
        "Where does the story happen?",
        "What do students learn?",
        "Who do they love?",
        "Why do they love him?"
      ],
      'answers': [
        "At school",
        "Reading, writing, and math",
        "The teacher",
        "Because he encourages them"
      ],
      'animation': 'assets/animations/school.json',
    },
    {
      'emoji': '🏖️',
      'title': 'Beach Vacation',
      'paragraph':
          'The family went to the beach on vacation. They built sandcastles, swam in the water, and ate delicious food under the warm sun.',
      'questions': [
        "Where did the family go?",
        "What did they build?",
        "Where did they swim?",
        "What did they eat?"
      ],
      'answers': [
        "To the beach",
        "Sandcastles",
        "In the water",
        "Delicious food"
      ],
      'animation': 'assets/animations/beach.json',
    },
  ];

  @override
  Widget build(BuildContext context) {
    _speak("Welcome to Level 3. Please choose a story to begin.");

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "📖 English - Level 3",
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
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
        children: [
          _buildTile(
            context,
            title: "Level 3 Quiz",
            jsonPath: "assets/animations/quiz.json",
            onTap: () {
              _speak("Let's start the final quiz.");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EnglishLevel3QuizAllScreen(),
                ),
              );
            },
          ),
          ...stories.map((story) {
            return _buildTile(
              context,
              title: story['title'],
              jsonPath: story['animation'],
              onTap: () {
                _speak("You selected: ${story["title"]}");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EnglishLevel3Screen(
                      title: story['title'],
                      storyText: story['paragraph'],
                      questions: List<String>.from(story['questions']),
                      correctAnswers: List<String>.from(story['answers']),
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
