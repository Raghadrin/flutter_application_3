import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

class CompareQuantitiesGame extends StatefulWidget {
  const CompareQuantitiesGame({super.key});

  @override
  State<CompareQuantitiesGame> createState() => _CompareQuantitiesGameState();
}

class _CompareQuantitiesGameState extends State<CompareQuantitiesGame> {
  final FlutterTts tts = FlutterTts();
  int currentIndex = 0;
  int score = 0;
  bool isCorrect = false;
  bool showNext = false;
  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;

  final List<Map<String, dynamic>> _questions = [
    {
      "imageA": "images/new_images/group_1_ball.PNG",
      "imageB": "images/new_images/group_4_ball.PNG",
      "answer": "B",
      "question": "Which group has more balls?"
    },
    {
      "imageA": "images/new_images/group_2_balls.png",
      "imageB": "images/new_images/group_4_balls.png",
      "answer": "B",
      "question": "Which group has more balls?"
    },
    {
      "imageA": "images/new_images/group_2_birds.PNG",
      "imageB": "images/new_images/group_4_birds.PNG",
      "answer": "B",
      "question": "Which group has more birds?"
    },
    {
      "imageA": "images/new_images/group_3_birds.PNG",
      "imageB": "images/new_images/group_5_birds.PNG",
      "answer": "B",
      "question": "Which group has more birds?"
    },
    {
      "imageA": "images/new_images/group_2_ducks.PNG",
      "imageB": "images/new_images/group_3_ducks.PNG",
      "answer": "B",
      "question": "Which group has more ducks?"
    },
    {
      "imageA": "images/new_images/group_3_fish.PNG",
      "imageB": "images/new_images/group_5_fish.PNG",
      "answer": "B",
      "question": "Which group has more fish?"
    },
    {
      "imageA": "images/new_images/group_3_apples.png",
      "imageB": "images/new_images/group_5_apples.png",
      "answer": "B",
      "question": "Which group has more apples?"
    },
    {
      "imageA": "images/new_images/group_5_stars.json",
      "imageB": "images/new_images/group_5_stars.json",
      "answer": "Yes",
      "question": "Do both groups have the same number of stars?",
      "options": ["Yes", "No"]
    },
    {
      "imageA": "images/new_images/group_5_ducks.PNG",
      "imageB": "images/new_images/group_3_ducks.PNG",
      "answer": "No",
      "question": "Do both groups have the same number of ducks?",
      "options": ["Yes", "No"]
    },
  ];

  @override
  void initState() {
    super.initState();
    _speakCurrent();
  }

  Future<void> _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45);
    await tts.speak(text);
  }

  void _speakCurrent() {
    _speak(_questions[currentIndex]['question']);
  }

  void _check(String selected) {
    final correct = _questions[currentIndex]['answer'];
    setState(() {
      isCorrect = selected == correct;
      showNext = true;
      if (isCorrect) {
        score += 10;
        feedbackMessage = "✅ Correct!";
        feedbackColor = Colors.green.shade200;
      } else {
        feedbackMessage = "❌ Wrong!";
        feedbackColor = Colors.red.shade200;
      }
    });

    _speak(isCorrect ? "Correct!" : "Wrong!");
  }

  void _next() {
    if (currentIndex < _questions.length - 1) {
      setState(() {
        currentIndex++;
        isCorrect = false;
        showNext = false;
        feedbackMessage = '';
        feedbackColor = Colors.transparent;
      });
      _speakCurrent();
    } else {
      _speak("Great job! You finished the game.");
      _showFinalDialog();
    }
  }

  String _getStars(int score, int total) {
    double ratio = score / (total * 10);
    if (ratio == 1.0) return "🌟🌟🌟";
    if (ratio >= 0.66) return "🌟🌟";
    if (ratio >= 0.33) return "🌟";
    return "⭐";
  }

  Future<void> _showFinalDialog() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🎉 Finished!", style: TextStyle(fontSize: 26)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Score: $score / ${_questions.length * 10}",
                style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 10),
            Text(_getStars(score, _questions.length),
                style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  currentIndex = 0;
                  score = 0;
                  showNext = false;
                  isCorrect = false;
                  feedbackMessage = '';
                  feedbackColor = Colors.transparent;
                });
                _speakCurrent();
              },
              child: const Text("🔁 Play Again"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMedia(String path) {
    if (path.endsWith('.json')) {
      return Lottie.asset(path, height: 120, width: 120);
    } else {
      return Image.asset(path, height: 120, width: 120);
    }
  }

  Widget _buildImage(String path, {required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Hero(
            tag: path,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.deepOrange, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(8),
              child: _buildMedia(path),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text("Compare Quantities"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text("Question ${currentIndex + 1} of ${_questions.length}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              const SizedBox(height: 16),
              Hero(
                tag: 'question-$currentIndex',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Text(
                    q['question'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (q['options'] != null)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildImage(q['imageA'], label: "Group A", onTap: () {}),
                        const SizedBox(width: 16),
                        _buildImage(q['imageB'], label: "Group B", onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      children: (q['options'] as List<String>).map((opt) {
                        return ElevatedButton(
                          onPressed: showNext ? null : () => _check(opt),
                          child: Text(opt, style: const TextStyle(fontSize: 22)),
                        );
                      }).toList(),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImage(q['imageA'], label: "A", onTap: () => _check("A")),
                    _buildImage(q['imageB'], label: "B", onTap: () => _check("B")),
                  ],
                ),
              const SizedBox(height: 24),
              if (feedbackMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: feedbackColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    feedbackMessage,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              if (showNext)
                ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text("Next", style: TextStyle(fontSize: 22)),
                )
            ],
          ),
        ),
      ),
    );
  }
}
