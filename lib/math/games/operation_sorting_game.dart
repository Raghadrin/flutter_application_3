import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OperationSortingGame extends StatefulWidget {
  const OperationSortingGame({super.key});

  @override
  State<OperationSortingGame> createState() => _OperationSortingGameState();
}

class _OperationSortingGameState extends State<OperationSortingGame> {
  final FlutterTts tts = FlutterTts();
  int currentIndex = 0;
  int score = 100;
  bool isCorrect = false;

  final List<Map<String, dynamic>> _questions = [
    {"equation": "4 ☐ 2 = 8", "answer": "*", "options": ["+", "-", "*", "/"]},
    {"equation": "9 ☐ 3 = 3", "answer": "/", "options": ["+", "-", "*", "/"]},
    {"equation": "6 ☐ 2 = 4", "answer": "-", "options": ["+", "-", "*", "/"]},
    {"equation": "3 ☐ 2 = 5", "answer": "+", "options": ["+", "-", "*", "/"]},
    {"equation": "5 ☐ 0 = 0", "answer": "*", "options": ["+", "-", "*", "/"]},
    {"equation": "10 ☐ 5 = 2", "answer": "/", "options": ["+", "-", "*", "/"]},
    {"equation": "7 ☐ 3 = 4", "answer": "-", "options": ["+", "-", "*", "/"]},
    {"equation": "2 ☐ 3 = 5", "answer": "+", "options": ["+", "-", "*", "/"]},
    {"equation": "8 ☐ 2 = 16", "answer": "*", "options": ["+", "-", "*", "/"]},
    {"equation": "6 ☐ 2 = 3", "answer": "/", "options": ["+", "-", "*", "/"]},
  ];

  @override
  void initState() {
    super.initState();
    _speakCurrent();
  }

  Future<void> _saveScore(int score) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final parentId = user.uid;
      final childrenSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .get();
      if (childrenSnapshot.docs.isEmpty) return;
      final childId = childrenSnapshot.docs.first.id;

      await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('math')
          .doc('math2')
          .collection('game2')
          .add({
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving score: $e");
    }
  }

  Future<void> _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45);
    await tts.speak(text);
  }

  void _speakCurrent() {
    final eq = _questions[currentIndex]['equation'];
    _speak("Which operation completes this equation: $eq");
  }

  void _check(String value) {
    final correct = _questions[currentIndex]['answer'];
    setState(() {
      isCorrect = value == correct;
      if (!isCorrect && score > 0) score -= 10;
    });
    _speak(isCorrect ? "Correct!" : "Wrong. Try the next one.");
  }

  void _next() {
    if (currentIndex < _questions.length - 1) {
      setState(() {
        currentIndex++;
        isCorrect = false;
      });
      _speakCurrent();
    } else {
      _speak("You finished all the questions.");
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
    await _saveScore(score);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🎉 Finished!", style: TextStyle(fontSize: 26)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Final Score: $score / ${_questions.length * 10}",
                style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 10),
            Text(_getStars(score, _questions.length),
                style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentIndex = 0;
                  score = 100;
                  isCorrect = false;
                });
                Navigator.pop(context);
                _speakCurrent();
              },
              child: const Text("🔁 Try Again", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose the Operation"),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: const Color(0xFFFFF3E0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              "Question ${currentIndex + 1} of ${_questions.length}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: const Text(
                "Which operation completes the equation?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                border: Border.all(color: Colors.deepOrange, width: 2),
              ),
              child: Text(
                q['equation'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: q["options"].map<Widget>((symbol) {
                return ElevatedButton(
                  onPressed: () => _check(symbol),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange.shade100,
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    symbol,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),
            if (isCorrect)
              const Text("✅ Correct!", style: TextStyle(fontSize: 26, color: Colors.green)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
              child: const Text("Next", style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}
