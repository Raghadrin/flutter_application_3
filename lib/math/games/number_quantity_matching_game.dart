import 'package:flutter/material.dart';
import 'package:flutter_application_3/math/theme.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class NumberQuantityMatchingGame extends StatefulWidget {
  const NumberQuantityMatchingGame({super.key});

  @override
  State<NumberQuantityMatchingGame> createState() =>
      _NumberQuantityMatchingGameState();
}

class _NumberQuantityMatchingGameState
    extends State<NumberQuantityMatchingGame> {
  final FlutterTts tts = FlutterTts();
  int currentIndex = 0;
  int score = 0;
  String? selected;
  bool isCorrect = false;

  final List<Map<String, dynamic>> _items = [
    {
      "image": "1_doll.jpg",
      "question": "How many dolls are there?",
      "options": ["1", "2", "3"],
      "answer": "1",
    },
    {
      "image": "4_cars.jpg",
      "question": "Count the cars!",
      "options": ["3", "4", "5"],
      "answer": "4",
    },
    {
      "image": "6_butterflies.jpg",
      "question": "How many butterflies do you see?",
      "options": ["6", "7", "8"],
      "answer": "6",
    },
    {
      "image": "8_pencils.png",
      "question": "Count the pencils.",
      "options": ["7", "8", "9"],
      "answer": "8",
    },
    {
      "image": "4_apples.png",
      "question": "How many apples are there?",
      "options": ["3", "4", "5"],
      "answer": "4",
    },
    {
      "image": "2_balls.png",
      "question": "How many balls can you count?",
      "options": ["1", "2", "3"],
      "answer": "2",
    },
    {
      "image": "group_5_stars.json",
      "question": "Count the stars!",
      "options": ["4", "5", "6"],
      "answer": "5",
    },
  ];

  @override
  void initState() {
    super.initState();
    _speakQuestion();
  }

  Future<void> _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45);
    await tts.speak(text);
  }

  void _speakQuestion() {
    _speak(_items[currentIndex]['question']);
  }

  void _check(String value) {
    final correct = _items[currentIndex]['answer'];
    setState(() {
      selected = value;
      isCorrect = (value == correct);
      if (isCorrect) score += 10;
    });

    _speak(isCorrect
        ? "That's correct!"
        : "Oops! That is not correct. Try again.");
  }

  void _next() {
    if (currentIndex < _items.length - 1) {
      setState(() {
        currentIndex++;
        selected = null;
        isCorrect = false;
      });
      _speakQuestion();
    } else {
      _speak("Well done! You scored $score out of ${_items.length * 10}.");
      _saveScore(score);
      _showFinalDialog();
    }
  }

  Future<void> _saveScore(int score) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final parentId = user.uid;
      final childSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .get();

      final childId =
          childSnapshot.docs.isNotEmpty ? childSnapshot.docs.first.id : null;

      if (childId == null) return;

      await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('math')
          .doc('math1')
          .collection('game2')
          .add({
        'score': score,
        'total': _items.length * 10,
        'percentage': score / (_items.length * 10),
        'correct': score ~/ 10,
        'wrong': _items.length - (score ~/ 10),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving score: $e");
    }
  }

  void _resetGame() {
    setState(() {
      currentIndex = 0;
      score = 0;
      selected = null;
      isCorrect = false;
    });
    _speakQuestion();
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
        title: const Text("🎉 Well done!",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You completed all questions!",
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text("Your Score: $score / ${_items.length * 10}",
                style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_getStars(score, _items.length),
                  style: const TextStyle(fontSize: 36)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text("🔁 Replay", style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("⬅️ Back", style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildVisual(String filename) {
    final path = "images/new_images/$filename";
    return filename.endsWith(".json")
        ? Lottie.asset(path, height: 160)
        : Image.asset(path, height: 160);
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[currentIndex];
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.appBarColor,
        title: const Text("Match Number to Quantity"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🟠 Progress Indicator
              Text(
                "Question ${currentIndex + 1} of ${_items.length}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 10),

              // Question text
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Text(
                  item["question"],
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

              // Image or animation
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.deepOrange, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 24),
                child: _buildVisual(item['image']),
              ),

              // Answer buttons
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: item["options"].map<Widget>((opt) {
                  final isCorrectAnswer = opt == item["answer"];
                  final isWrong = selected == opt && !isCorrectAnswer;

                  Color color;
                  if (selected == null) {
                    color = Colors.orangeAccent;
                  } else if (isCorrectAnswer) {
                    color = isCorrect ? Colors.green : Colors.grey;
                  } else if (isWrong) {
                    color = Colors.red;
                  } else {
                    color = Colors.grey[300]!;
                  }

                  return ElevatedButton(
                    onPressed: isCorrect || selected == null ? () => _check(opt) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(opt, style: const TextStyle(fontSize: 28)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Next button
              ElevatedButton.icon(
                onPressed: _next,
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Next",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent.shade100,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
