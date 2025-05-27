
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
    {"question": "(2 + 3) × 2", "image": "2_plus_3_times_2.png", "options": ["8", "10", "12"], "answer": "10"},
    {"question": "(6 + 4) × 2", "image": "6_plus_4_times_2.png", "options": ["14", "20", "18"], "answer": "14"},
    {"question": "(8 - 2) × 3", "image": "8_minus_2_times_3.png", "options": ["2", "6", "18"], "answer": "2"},
    {"question": "(9 + 3) × 2", "image": "9_plus_3_times_2.PNG", "options": ["12", "15", "18"], "answer": "15"},
    {"question": "(20 ÷ 5) + 6", "image": "20_div_5_plus_6.PNG", "options": ["8", "9", "10"], "answer": "10"},
    {"question": "(15 - 3) × 3", "image": "15minu3times3.PNG", "options": ["6", "9", "3"], "answer": "6"},
    {"question": "(4 + 2) × (1 + 1)", "image": "4_plus_2_times_1_plus_1.PNG", "options": ["12", "10", "8"], "answer": "12"},
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final parentId = user.uid;
      final childSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .get();
      final childId = childSnapshot.docs.isNotEmpty ? childSnapshot.docs.first.id : null;

      if (childId == null) return;

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
        'total': _questions.length * 10,
        'percentage': score / (_questions.length * 10),
        'correct': score ~/ 10,
        'wrong': _questions.length - (score ~/ 10),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving score: $e");
    }
  }

  void _speakCurrent() {
    _speak("Solve the equation: ${_questions[currentIndex]['question']}");
  }

  void _check(String value) {
    final correct = _questions[currentIndex]['answer'];
    setState(() {
      isCorrect = (value == correct);
      showNext = true;
      if (isCorrect) score += 10;
    });
    _speak(isCorrect ? "Correct!" : "That is not correct.");
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
      _speak("You completed all hard equations. Well done!");
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
            Text("Score: $score / ${_questions.length * 10}", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text(_getStars(score, _questions.length * 10), style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetGame,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("🔁 Play Again", style: TextStyle(fontSize: 20)),
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
              Text("Question ${currentIndex + 1} of ${_questions.length}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.deepOrange)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: const Text(
                  "What is the result of this equation?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
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
                      fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
              ),
              if (q['image'] != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    border: Border.all(color: Colors.deepOrange, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Image.asset("images/new_images/${q['image']}", height: 160),
                ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(opt, style: const TextStyle(fontSize: 24)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              if (isCorrect)
                const Text("✅ Correct!", style: TextStyle(fontSize: 22, color: Colors.green)),
              if (showNext)
                ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text("Next", style: TextStyle(fontSize: 22)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
