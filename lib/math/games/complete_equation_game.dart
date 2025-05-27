import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompleteEquationGame extends StatefulWidget {
  const CompleteEquationGame({super.key});

  @override
  State<CompleteEquationGame> createState() => _CompleteEquationGameState();
}

class _CompleteEquationGameState extends State<CompleteEquationGame> {
  final FlutterTts tts = FlutterTts();
  int currentIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool answered = false;
  bool isCorrect = false;

  final List<Map<String, dynamic>> _questions = [
    {"equationParts": ["2", "+", "3", "=", "_"], "answer": "5", "options": ["4", "5", "6"], "image": "2_+_3_=_blank.PNG"},
    {"equationParts": ["_", "+", "6", "=", "9"], "answer": "3", "options": ["2", "3", "4"], "image": "blank_+_6_=_9.PNG"},
    {"equationParts": ["4", "+", "_", "=", "7"], "answer": "3", "options": ["2", "3", "5"], "image": "4_+_blank_=_7.PNG"},
    {"equationParts": ["5", "+", "2", "=", "_"], "answer": "7", "options": ["6", "7", "8"], "image": "5_+_2_=_blank.PNG"},
    {"equationParts": ["_", "+", "4", "=", "6"], "answer": "2", "options": ["1", "2", "3"], "image": "blank_+_4_=_6.PNG"},
    {"equationParts": ["8", "+", "_", "=", "15"], "answer": "7", "options": ["6", "7", "8"], "image": "8_+_blank_=_15.png"},
    {"equationParts": ["3", "+", "_", "=", "4"], "answer": "1", "options": ["1", "2", "3"], "image": "3_+_blank_=_4.png"},
    {"equationParts": ["3", "+", "1", "=", "_"], "answer": "4", "options": ["3", "4", "5"], "image": "3_+_1_=_blank.png"},
    {"equationParts": ["6", "+", "_", "=", "9"], "answer": "3", "options": ["2", "3", "4"], "image": "6_+_blank_=_9.png"},
    {"equationParts": ["4", "+", "7", "=", "_"], "answer": "11", "options": ["10", "11", "12"], "image": "4_+_7_=_blank.png"},
  ];

  @override
  void initState() {
    super.initState();
    _speakCurrentEquation();
  }

  Future<void> _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45);
    await tts.speak(text);
  }

  Future<void> _speakCurrentEquation() async {
    final parts = _questions[currentIndex]['equationParts'] as List<String>;
    final speakMap = {
      '+': 'plus',
      '=': 'equals',
      '_': 'blank',
      '0': 'zero',
      '1': 'one',
      '2': 'two',
      '3': 'three',
      '4': 'four',
      '5': 'five',
      '6': 'six',
      '7': 'seven',
      '8': 'eight',
      '9': 'nine',
      '10': 'ten',
      '11': 'eleven',
      '12': 'twelve',
      '13': 'thirteen',
      '15': 'fifteen'
    };
    for (final part in parts) {
      await _speak(speakMap[part] ?? part);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> _saveScore() async {
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
          .doc('math1')
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

  void _checkAnswer(String value) {
    final correct = _questions[currentIndex]['answer'];
    setState(() {
      answered = true;
      selectedAnswer = value;
      isCorrect = (value == correct);
      if (isCorrect) score += 10;
    });
    _speak(isCorrect ? "Correct!" : "Try again!");
  }

  void _next() {
    if (currentIndex < _questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
        answered = false;
        isCorrect = false;
      });
      _speakCurrentEquation();
    } else {
      _speak("Well done! Your final score is $score.");
      _saveScore();
      _showFinalDialog();
    }
  }

  void _reset() {
    setState(() {
      currentIndex = 0;
      score = 0;
      selectedAnswer = null;
      answered = false;
      isCorrect = false;
    });
    _speakCurrentEquation();
  }

  void _showFinalDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🎉 Finished!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        content: Text("Your Score: $score / ${_questions.length * 10}", style: const TextStyle(fontSize: 22)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            child: const Text("🔁 Play Again", style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildEquationBox() {
    final parts = _questions[currentIndex]['equationParts'] as List<String>;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.orange, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: parts.map((part) {
          final isNumber = RegExp(r'^\d+$').hasMatch(part);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              part,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isNumber ? Colors.orange : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete the Equation"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      backgroundColor: Colors.orange[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "What number completes the equation?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ),
            _buildEquationBox(),
            const SizedBox(height: 16),
            if (q["image"] != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange.withOpacity(0.5), width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  "images/new_images/${q["image"]}",
                  height: 140,
                ),
              ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: (q['options'] as List<String>).map((opt) {
                Color color;
                if (selectedAnswer == null) {
                  color = Colors.orangeAccent;
                } else if (opt == q['answer']) {
                  color = isCorrect ? Colors.green : Colors.grey;
                } else if (opt == selectedAnswer) {
                  color = Colors.red;
                } else {
                  color = Colors.grey[300]!;
                }

                return ElevatedButton(
                  onPressed: answered ? null : () => _checkAnswer(opt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(opt, style: const TextStyle(fontSize: 28)),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            if (answered)
              ElevatedButton.icon(
                onPressed: _next,
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Next", style: TextStyle(fontSize: 22)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent.shade100,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              )
          ],
        ),
      ),
    );
  }
}
