import 'package:flutter/material.dart';
import 'sentence_learning_screen.dart';

class EnglishLevel1Screen extends StatelessWidget {
  final List<Map<String, String>> stories = [
    {
      "title": " The Apple",
      "emoji": "🍎",
      "sentence": "The apple is red and sweet.",
      "image": "images/Apple.png",
    },
    {
      "title": "My School",
      "emoji": "🏫",
      "sentence": "I go to school every morning.",
      "image": "images/School.jpg",
    },
    {
      "title": " My Dog",
      "emoji": "🐶",
      "sentence": "My dog runs fast in the park.",
      "image": "images/Mydog.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: Text("English Level 1"),
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: Column(
              children: stories.map((story) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SentenceLearningScreen(
                          sentence: story["sentence"]!,
                          title: story["title"]!,
                          imagePath: story["image"]!,
                          motivational: true,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(2, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(2, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            story["emoji"]!,
                            style: const TextStyle(fontSize: 36),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          story["title"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
