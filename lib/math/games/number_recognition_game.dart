import 'package:flutter/material.dart';
import 'package:flutter_application_3/math/theme.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NumberRecognitionGame extends StatefulWidget {
  const NumberRecognitionGame({super.key});

  @override
  State<NumberRecognitionGame> createState() => _NumberRecognitionGameState();
}

class _NumberRecognitionGameState extends State<NumberRecognitionGame> {
  final FlutterTts tts = FlutterTts();
  int currentIndex = 0;
  int score = 0;
  bool isCorrect = false;
  String parentId = '';
  String? childId;
  String? selectedAnswer;
  bool answered = false;

  final List<Map<String, dynamic>> _numbers = [
    {"number": "1", "image": "1_lemon.png", "options": ["1", "2", "3"], "answer": "1"},
    {"number": "2", "image": "2_oranges.png", "options": ["1", "2", "3"], "answer": "2"},
    {"number": "3", "image": "3_apples.png", "options": ["2", "3", "4"], "answer": "3"},
    {"number": "4", "image": "4_watermolns.png", "options": ["3", "4", "5"], "answer": "4"},
    {"number": "5", "image": "5_balls.png", "options": ["4", "5", "6"], "answer": "5"},
    {"number": "6", "image": "6_strawberries.png", "options": ["5", "6", "7"], "answer": "6"},
    {"number": "7", "image": "7_peaches.png", "options": ["6", "7", "8"], "answer": "7"},
    {"number": "8", "image": "8_pears.png", "options": ["7", "8", "9"], "answer": "8"},
    {"number": "9", "image": "9_bananas.png", "options": ["8", "9", "10"], "answer": "9"},
    {"number": "10", "image": "10_cherries.png", "options": ["9", "10", "11"], "answer": "10"},
  ];

  @override
  void initState() {
    super.initState();
    _initializeIdsAndStart();
  }

  Future<void> _initializeIdsAndStart() async {
    await fetchParentId();
    final fetchedChildId = await fetchChildId();
    if (fetchedChildId != null) {
      setState(() => childId = fetchedChildId);
    }
    _speakCurrentQuestion();
  }

  Future<void> fetchParentId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    parentId = user.uid;
    final parentRef = FirebaseFirestore.instance.collection('parents').doc(parentId);
    final parentDoc = await parentRef.get();
    if (!parentDoc.exists) {
      await parentRef.set({
        'createdAt': FieldValue.serverTimestamp(),
        'email': user.email,
      });
    }
  }

  Future<String?> fetchChildId() async {
    if (parentId.isEmpty) return null;
    final childrenSnapshot = await FirebaseFirestore.instance
        .collection('parents')
        .doc(parentId)
        .collection('children')
        .get();
    return childrenSnapshot.docs.isNotEmpty ? childrenSnapshot.docs.first.id : null;
  }

  Future<void> _saveGameResult({
    required int score,
    required int totalQuestions,
    required DateTime playedAt,
  }) async {
    if (parentId.isEmpty || childId == null) return;
    await FirebaseFirestore.instance
        .collection('parents')
        .doc(parentId)
        .collection('children')
        .doc(childId)
        .collection('math')
        .doc('math1')
        .collection('game1')
        .add({
      'score': score,
      'total': totalQuestions * 10,
      'percentage': score / (totalQuestions * 10),
      'correct': score ~/ 10,
      'wrong': totalQuestions - (score ~/ 10),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45);
    await tts.speak(text);
  }

  void _speakCurrentQuestion() {
    final item = _numbers[currentIndex];
    _speak("How many items do you see? Choose the correct number. This is number ${item['number']}");
  }

  void _checkAnswer(String selected) {
    final correct = _numbers[currentIndex]['answer'];
    setState(() {
      answered = true;
      selectedAnswer = selected;
      isCorrect = (selected == correct);
      if (isCorrect) score += 10;
    });
    _speak(isCorrect ? "Great! That is correct." : "That was not correct. Try again.");
  }

  void _next() {
    if (currentIndex < _numbers.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
        isCorrect = false;
        answered = false;
      });
      _speakCurrentQuestion();
    } else {
      _speak("You finished the game! Great job!");
      _showFinalDialog();
      _saveGameResult(
        score: score,
        totalQuestions: _numbers.length,
        playedAt: DateTime.now(),
      );
    }
  }

  void _resetGame() {
    setState(() {
      currentIndex = 0;
      score = 0;
      isCorrect = false;
      selectedAnswer = null;
      answered = false;
    });
    _speakCurrentQuestion();
    Navigator.pop(context);
  }

  String _getStars(int score, int total) {
    double ratio = score / (total * 10);
    if (ratio == 1.0) return "🌟🌟🌟";
    if (ratio >= 0.66) return "🌟🌟";
    if (ratio >= 0.33) return "🌟";
    return "⭐";
  }

  void _showFinalDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("🎉 Well done!",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Your Score: $score / ${_numbers.length * 10}",
                style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 10),
            Text(_getStars(score, _numbers.length),
                style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text("🔁 Play Again", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _numbers[currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.appBarColor,
        title: const Text("Recognize the Number"),
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
                "Question ${currentIndex + 1} of ${_numbers.length}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: const Text(
                  "How many items do you see? Choose the correct number.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item["number"],
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  border: Border.all(color: Colors.deepOrange, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset("images/new_images/${item["image"]}",
                    height: 150),
              ),
              const SizedBox(height: 30),

              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: item["options"].map<Widget>((option) {
                  Color buttonColor;

                  if (selectedAnswer == null) {
                    buttonColor = Colors.orangeAccent;
                  } else if (option == item["answer"]) {
                    buttonColor = isCorrect ? Colors.green : Colors.grey;
                  } else if (option == selectedAnswer) {
                    buttonColor = Colors.red;
                  } else {
                    buttonColor = Colors.grey[300]!;
                  }

                  return ElevatedButton(
                    onPressed: isCorrect || selectedAnswer == null
                        ? () => _checkAnswer(option)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(option, style: const TextStyle(fontSize: 28)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
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
