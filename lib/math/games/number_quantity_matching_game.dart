import 'package:flutter/material.dart';
import 'package:flutter_application_3/math/theme.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NumberQuantityMatchingGame extends StatefulWidget {
  const NumberQuantityMatchingGame({super.key});

  @override
  State<NumberQuantityMatchingGame> createState() =>
      _NumberQuantityMatchingGameState();
}

class _NumberQuantityMatchingGameState
    extends State<NumberQuantityMatchingGame> {
  final FlutterTts tts = FlutterTts();
  late ConfettiController _confettiController;
  int currentIndex = 0;
  int score = 0;
  String? selected;
  bool isCorrect = false;

  final List<Map<String, dynamic>> _items = [
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
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _speakQuestion();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _saveScore(int score) async {
    try {
      // Fetch parentId and childId, adapt this to your actual method:
      String? parentId = ""; // fetch parentId from your auth or Firestore
      String? childId = ""; // fetch childId from your app logic

      // Example: fetch from Firestore assuming current user is parent
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in");
        return;
      }
      parentId = user.uid;

      // For childId, assuming you select or fetch it earlier, just set here for testing
      childId =
          "exampleChildId"; // replace with your actual logic to get childId

      if (parentId.isEmpty || childId == null) {
        print("Cannot save score: parentId or childId missing");
        return;
      }

      // Save to Firestore: example path 'parents/{parentId}/children/{childId}/scores'
      await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('math')
          .doc('math1')
          .collection('game2') // or game2
          .add({
        'score': score,
        'total': _items.length,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Score saved successfully");
    } catch (e) {
      print("Error saving score: $e");
    }
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
      if (isCorrect) score++;
    });

    if (isCorrect) {
      _speak("That's correct!");
      Future.delayed(const Duration(seconds: 2), _next);
    } else {
      _speak("Try again!");
    }
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
      _speak(
          "Well done! You got $score out of ${_items.length}. Would you like to try again or go back?");
      _confettiController.play();
      _showFinalDialog();
    }
  }

  void _resetGame() {
    setState(() {
      currentIndex = 0;
      score = 0;
      selected = null;
      isCorrect = false;
      _items.shuffle(); // Optional: randomize questions
    });
    _speakQuestion();
  }

  Future<void> _showFinalDialog() async {
    await _saveScore(score);
    showDialog(
      context: context,
      builder: (_) => Stack(
        alignment: Alignment.topCenter,
        children: [
          AlertDialog(
            backgroundColor: Colors.white,
            title: const Text("🎉 Good Job!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("You finished all the questions!",
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text("Your Score: $score / ${_items.length}",
                    style: const TextStyle(fontSize: 22)),
                Text(_getStars(score, _items.length),
                    style: const TextStyle(fontSize: 36)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetGame();
                },
                child: const Text("🔄 Replay", style: TextStyle(fontSize: 20)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("⬅️ Back", style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 30,
            maxBlastForce: 20,
            minBlastForce: 5,
            emissionFrequency: 0.05,
            gravity: 0.3,
          ),
        ],
      ),
    );
  }

  String _getStars(int score, int total) {
    double ratio = score / total;
    if (ratio == 1.0) return "🌟🌟🌟";
    if (ratio >= 0.66) return "🌟🌟";
    if (ratio >= 0.33) return "🌟";
    return "⭐";
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
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Text(
                  item["question"],
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  border: Border.all(color: Colors.deepOrange, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 24),
                child: _buildVisual(item['image']),
              ),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: item["options"].map<Widget>((opt) {
                  final isRight = isCorrect && opt == item["answer"];
                  final isWrong = selected == opt && opt != item["answer"];
                  return ElevatedButton(
                    onPressed: () => _check(opt),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRight
                          ? Colors.green
                          : isWrong
                              ? Colors.red
                              : Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(opt, style: const TextStyle(fontSize: 28)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
