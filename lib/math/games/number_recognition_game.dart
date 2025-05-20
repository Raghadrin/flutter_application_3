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

  final List<Map<String, dynamic>> _numbers = [
    {
      "number": "3",
      "image": "3_apples.png",
      "options": ["2", "3", "4"],
      "answer": "3",
    },
    {
      "number": "5",
      "image": "5_balls.png",
      "options": ["4", "5", "6"],
      "answer": "5",
    },
    {
      "number": "2",
      "image": "2_oranges.png",
      "options": ["1", "2", "3"],
      "answer": "2",
    },
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
      setState(() {
        childId = fetchedChildId;
      });
    } else {
      print("No child ID found.");
    }
  }

  Future<void> fetchParentId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      parentId = user.uid;

      final parentRef =
          FirebaseFirestore.instance.collection('parents').doc(parentId);
      final parentDoc = await parentRef.get();

      if (!parentDoc.exists) {
        await parentRef.set({
          'createdAt': FieldValue.serverTimestamp(),
          'email': user.email,
        });
        print("Parent ID created successfully!");
      }
    } catch (e) {
      print("Error creating parent ID: $e");
    }
  }

  Future<String?> fetchChildId() async {
    try {
      if (parentId.isEmpty) return null;

      final childrenSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .get();

      if (childrenSnapshot.docs.isNotEmpty) {
        return childrenSnapshot.docs.first.id;
      } else {
        print("No children found for this parent.");
        return null;
      }
    } catch (e) {
      print("Error fetching child ID: $e");
      return null;
    }
  }

  Future<void> _saveGameResult({
    required int score,
    required int totalQuestions,
    required DateTime playedAt,
  }) async {
    // print('DEBUG: parentId="$parentId", childId="$childId"');

    if (parentId.isEmpty || childId == null) {
      print("Cannot save game result: parentId or childId missing");
      return;
    }

    try {
      final gameData = {
        'score': score,
        'totalQuestions': totalQuestions,
        'playedAt': playedAt,
      };

      await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('math')
          .doc('math1')
          .collection('game1') // or game2
          .add({
        'score': score,
        //'total': _items.length,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Game result saved successfully!");
    } catch (e) {
      print("Error saving game result: $e");
    }
  }

  Future<void> _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45);
    await tts.speak(text);
  }

  void _speakCurrentQuestion() {
    final item = _numbers[currentIndex];
    _speak(
        "How many items do you see? Choose the correct number. This is number ${item['number']}");
  }

  void _checkAnswer(String selected) {
    final correct = _numbers[currentIndex]['answer'];
    setState(() {
      isCorrect = (selected == correct);
      if (isCorrect) score++;
    });

    if (isCorrect) {
      _speak("Great! That is correct.");
      Future.delayed(const Duration(seconds: 2), _next);
    } else {
      _speak("Try again!");
    }
  }

  Future<void> _next() async {
    if (currentIndex < _numbers.length - 1) {
      setState(() {
        currentIndex++;
        isCorrect = false;
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
    });
    _speakCurrentQuestion();
    Navigator.pop(context);
  }

  String _getStars(int score, int total) {
    double ratio = score / total;
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
            Text("Your Score: $score / ${_numbers.length}",
                style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 10),
            Text(_getStars(score, _numbers.length),
                style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child:
                  const Text("🔁 Play Again", style: TextStyle(fontSize: 20)),
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
              // Score box
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
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                width: screenWidth * 0.85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: const Text(
                  "How many items do you see? Choose the correct number.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              // Transparent number box
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
                      color: Colors.deepOrange),
                ),
              ),
              const SizedBox(height: 20),

              // Image box
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

              // Answer options
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: item["options"].map<Widget>((option) {
                  final isRight = isCorrect && option == item["answer"];
                  return ElevatedButton(
                    onPressed: () => _checkAnswer(option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isRight ? Colors.green : Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(option, style: const TextStyle(fontSize: 28)),
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
