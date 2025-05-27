import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReverseEquationGame extends StatefulWidget {
  const ReverseEquationGame({super.key});

  @override
  State<ReverseEquationGame> createState() => _ReverseEquationGameState();
}

class _ReverseEquationGameState extends State<ReverseEquationGame> {
  final FlutterTts tts = FlutterTts();
  int currentIndex = 0;
  int score = 0;
  bool isCorrect = false;
  bool showNext = false;
  String? selected;

  final List<Map<String, dynamic>> _questions = [
    {
      "equation": "x × 3 + 3 = 18",
      "question": "What is the value of x?",
      "options": ["5", "6", "4"],
      "answer": "5",
      "image": "reverse_eq_1.png"
    },
    {
      "equation": "x + 4 = 10",
      "question": "What is the value of x?",
      "options": ["6", "7", "5"],
      "answer": "6",
      "image": "reverse_eq_2.png"
    },
    {
      "equation": "20 = x × 4",
      "question": "What is the value of x?",
      "options": ["5", "4", "6"],
      "answer": "5",
      "image": "reverse_eq_3.png"
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
    final q = _questions[currentIndex];
    _speak("${q['equation']}. ${q['question']}");
  }

  void _check(String value) {
    final correct = _questions[currentIndex]['answer'];
    setState(() {
      selected = value;
      isCorrect = (value == correct);
      showNext = true;
      if (isCorrect) score += 10;
    });
    _speak(isCorrect ? "Correct!" : "Try again!");
  }

  void _next() {
    if (currentIndex < _questions.length - 1) {
      setState(() {
        currentIndex++;
        isCorrect = false;
        showNext = false;
        selected = null;
      });
      _speakCurrent();
    } else {
      _speak("Great job! Your score is $score out of ${_questions.length * 10}.");
      _saveScore();
      _showFinalDialog();
    }
  }

  Future<void> _saveScore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final parentId = user.uid;

      final childrenSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .get();
      final childId = childrenSnapshot.docs.isNotEmpty ? childrenSnapshot.docs.first.id : null;
      if (childId == null) return;

      await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('math')
          .doc('math3')
          .collection('game2')
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

  void _showFinalDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("🎉 Well done!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Your Score: $score / ${_questions.length * 10}", style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 10),
            Text(_getStars(score, _questions.length), style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("🔁 Replay", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  String _getStars(int score, int total) {
    double ratio = score / (total * 10);
    if (ratio == 1.0) return "🌟🌟🌟";
    if (ratio >= 0.66) return "🌟🌟";
    if (ratio >= 0.33) return "🌟";
    return "⭐";
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reverse Equation Game"),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: const Color(0xFFFFF6ED),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Question ${currentIndex + 1} of ${_questions.length}",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              const SizedBox(height: 16),

              // Equation Box
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.deepOrange, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(q['equation'],
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.orange)),
              ),

              // Question Text in white box with subtle shadow
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
                  ],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(q['question'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
              ),

              if (q['image'] != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.08),
                    border: Border.all(color: Colors.deepOrange, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset("images/new_images/${q['image']}", height: 150),
                ),

              const SizedBox(height: 24),

              Wrap(
                spacing: 20,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: q['options'].map<Widget>((opt) {
                  final isSelected = selected == opt;
                  final correct = opt == q["answer"];
                  Color color = Colors.orangeAccent.shade100;

                  if (selected != null) {
                    if (correct) {
                      color = Colors.green;
                    } else if (isSelected) {
                      color = Colors.redAccent;
                    } else {
                      color = Colors.grey.shade300;
                    }
                  }

                  return ElevatedButton(
                    onPressed: showNext ? null : () => _check(opt),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(opt, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _next,
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Next", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent.shade100,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
