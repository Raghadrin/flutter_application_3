import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HardEquationGame extends StatefulWidget {
  const HardEquationGame({super.key});

  @override
  State<HardEquationGame> createState() => _HardEquationGameState();
}

class _HardEquationGameState extends State<HardEquationGame> {
  final FlutterTts tts = FlutterTts();
  int currentIndex = 0;
  int score = 0;
  bool isCorrect = false;
  bool showNext = false;

  final List<Map<String, dynamic>> _questions = [
    {
      "question": "(2 + 3) × 2 = ?",
      "image": "2_plus_3_times_2.png",
      "options": ["8", "10", "12"],
      "answer": "10"
    },
    {
      "question": "6 + 4 × 2 = ?",
      "image": "6_plus_4_times_2.png",
      "options": ["14", "20", "18"],
      "answer": "14"
    },
    {
      "question": "8 - 2 × 3 = ?",
      "image": "8_minus_2_times_3.png",
      "options": ["2", "6", "18"],
      "answer": "2"
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

      final childrenSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .get();
      if (childrenSnapshot.docs.isNotEmpty) {
        childId = childrenSnapshot.docs.first.id;
      } else {
        print("No children found for this parent.");
        return null;
      }

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
          .doc('math2')
          .collection('game3')
          .add({
        'score': score,
        //'total': _items.length,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Score saved successfully");
    } catch (e) {
      print("Error saving score: $e");
    }
  }

  void _speakCurrent() {
    _speak("What is the answer for: ${_questions[currentIndex]['question']}");
  }

  void _check(String value) {
    final correct = _questions[currentIndex]['answer'];
    setState(() {
      isCorrect = (value == correct);
      showNext = isCorrect;
      if (isCorrect) score++;
    });

    _speak(isCorrect ? "Correct!" : "Try again!");
  }

  void _next() {
    if (currentIndex < _questions.length - 1) {
      setState(() {
        currentIndex++;
        isCorrect = false;
        showNext = false;
      });
      _speakCurrent();
    } else {
      _speak("You completed all advanced equations. Great job!");
      _showFinalDialog();
    }
  }

  void _resetGame() {
    setState(() {
      currentIndex = 0;
      score = 0;
      isCorrect = false;
      showNext = false;
    });
    _speakCurrent();
    Navigator.pop(context);
  }

  String _getStars(int score, int total) {
    double ratio = score / total;
    if (ratio == 1.0) return "🌟🌟🌟";
    if (ratio >= 0.66) return "🌟🌟";
    if (ratio >= 0.33) return "🌟";
    return "⭐";
  }

  Future<void> _showFinalDialog() async {
    await _saveScore(score);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🎉 Finished!", style: TextStyle(fontSize: 26)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You solved all hard equations!",
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text("Score: $score / ${_questions.length}",
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text(_getStars(score, _questions.length),
                style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetGame,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child:
                  const Text("🔁 Play Again", style: TextStyle(fontSize: 20)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hard Equations"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFF6ED),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Score tracker
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text("🏆 Score: $score",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              // Question box
              Container(
                width: screenWidth * 0.85,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Text(
                  "What is the result of this equation?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              // Transparent equation
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  q['question'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange),
                ),
              ),
              // Image visual
              if (q['image'] != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    border: Border.all(color: Colors.deepOrange, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Image.asset("images/new_images/${q['image']}",
                      height: 160),
                ),
              // Options
              Wrap(
                spacing: 20,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: q["options"].map<Widget>((opt) {
                  final correct = opt == q["answer"];
                  final bgColor = isCorrect && correct
                      ? Colors.green
                      : Colors.orangeAccent.shade100;
                  return ElevatedButton(
                    onPressed: showNext ? null : () => _check(opt),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bgColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(opt, style: const TextStyle(fontSize: 24)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              if (isCorrect)
                const Text("✅ Correct!",
                    style: TextStyle(fontSize: 22, color: Colors.green)),
              if (showNext)
                ElevatedButton(
                  onPressed: _next,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text("Next", style: TextStyle(fontSize: 22)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
