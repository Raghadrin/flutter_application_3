import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MultiStepEquationGame extends StatefulWidget {
  const MultiStepEquationGame({super.key});

  @override
  State<MultiStepEquationGame> createState() => _MultiStepEquationGameState();
}

class _MultiStepEquationGameState extends State<MultiStepEquationGame>
    with SingleTickerProviderStateMixin {
  final FlutterTts tts = FlutterTts();
  int currentIndex = 0;
  int score = 0;
  bool finished = false;
  String? droppedAnswer;
  bool wrongDrop = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final List<Map<String, dynamic>> _questions = [
    {
      "question": "First: 2 + 3 = 5, then × 2 = ?",
      "image": "2_plus_3_then_times_2.png",
      "options": ["8", "10", "12"],
      "answer": "10"
    },
    {
      "question": "First: 10 - 4 = 6, then × 3 = ?",
      "image": "10_minus_4_then_times_3.png",
      "options": ["18", "16", "12"],
      "answer": "18"
    },
    {
      "question": "First: 5 × 2 = 10, then - 1 = ?",
      "image": "5_times_2_then_minus_1.png",
      "options": ["9", "10", "8"],
      "answer": "9"
    },
  ];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
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
          .doc('math3')
          .collection('game1')
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
    _speak(_questions[currentIndex]['question']);
  }

  void _checkDroppedAnswer(String answer) async {
    final correct = _questions[currentIndex]['answer'];
    setState(() {
      droppedAnswer = answer;
      wrongDrop = false;
    });

    if (answer == correct) {
      score++;
      await _speak("Correct. $answer is the right answer.");
      await Future.delayed(const Duration(milliseconds: 800));
      _next();
    } else {
      await _speak("Oops. $answer is incorrect. Try again.");
      setState(() {
        droppedAnswer = null;
        wrongDrop = true;
        _shakeController.forward(from: 0);
      });
    }
  }

  Future<void> _next() async {
    if (currentIndex < _questions.length - 1) {
      setState(() {
        currentIndex++;
        droppedAnswer = null;
        wrongDrop = false;
      });
      _speakCurrent();
    } else {
      setState(() => finished = true);
      _speak(
          "Great work! Your score is $score out of ${_questions.length}. Would you like to try again?");
      await _saveScore(score);
    }
  }

  void _resetGame() {
    setState(() {
      currentIndex = 0;
      score = 0;
      droppedAnswer = null;
      wrongDrop = false;
      finished = false;
    });
    _speakCurrent();
  }

  String _getStars(int score, int total) {
    double ratio = score / total;
    if (ratio == 1.0) return "🌟🌟🌟";
    if (ratio >= 0.66) return "🌟🌟";
    if (ratio >= 0.33) return "🌟";
    return "⭐";
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
          title: const Text("Multi-Step Equation Game"),
          backgroundColor: Colors.orange),
      backgroundColor: const Color(0xFFFFF6ED),
      body: Center(
        child: finished
            ? Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("🎉 Well done!",
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Your Score: $score / ${_questions.length}",
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 10),
                      Text(_getStars(score, _questions.length),
                          style: const TextStyle(fontSize: 36)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _resetGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: const Text("🔁 Play Again",
                            style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Score Box Centered
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ],
                      ),
                      child: Text("🏆 Score: $score",
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ),

                    // Question
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.deepOrange, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        q['question'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange),
                      ),
                    ),

                    // Image
                    if (q['image'] != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.1),
                          border:
                              Border.all(color: Colors.deepOrange, width: 3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Image.asset("images/new_images/${q['image']}",
                            height: 160),
                      ),

                    // Drop Target
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: DragTarget<String>(
                        builder: (context, candidateData, rejectedData) =>
                            Container(
                          height: 60,
                          width: 240,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color:
                                    wrongDrop ? Colors.red : Colors.deepOrange,
                                width: 3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            droppedAnswer ?? " Drop your answer here",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .deepOrange, // ✅ Enhanced hint visibility
                            ),
                          ),
                        ),
                        onWillAccept: (_) => true,
                        onAccept: _checkDroppedAnswer,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Wrap(
                      spacing: 20,
                      children: (q['options'] as List<String>).map((opt) {
                        return Draggable<String>(
                          data: opt,
                          feedback: Material(
                            color: Colors.transparent,
                            child: _buildOption(opt),
                          ),
                          childWhenDragging:
                              Opacity(opacity: 0.4, child: _buildOption(opt)),
                          child: _buildOption(opt),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOption(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(
            color: wrongDrop ? Colors.red : Colors.deepOrange, width: 3),
        color: Colors.orangeAccent.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
    );
  }
}
