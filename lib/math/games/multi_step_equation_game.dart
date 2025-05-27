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
    {"question": "First: 2 + 3 = 5, then × 2 = ?", "image": "2_plus_3_times_2.png", "options": ["8", "10", "12"], "answer": "10"},
    {"question": "First: 10 - 4 = 6, then × 3 = ?", "image": "10_minus_4_then_times_3.png", "options": ["18", "16", "12"], "answer": "18"},
    {"question": "First: 5 × 2 = 10, then - 1 = ?", "image": "5_times_2_then_minus_1.png", "options": ["9", "10", "8"], "answer": "9"},
    {"question": "First: 4 + 4 = 8, then ÷ 2 = ?", "image": "4_plus_4_then_div_2.PNG", "options": ["4", "6", "2"], "answer": "4"},
    {"question": "First: 6 × 2 = 12, then - 5 = ?", "image": "6_times_2_then_minus_5.PNG", "options": ["7", "6", "8"], "answer": "7"},
    {"question": "First: 9 - 3 = 6, then + 4 = ?", "image": "9_minus_3_then_plus_4.PNG", "options": ["10", "11", "12"], "answer": "10"},
    {"question": "First: 8 ÷ 2 = 4, then × 3 = ?", "image": "8_div_2_then_times_3.PNG", "options": ["10", "12", "14"], "answer": "12"}
  ];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnimation = Tween<double>(begin: 0, end: 10).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
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
          .collection('game1')
          .add({
        'score': score,
        'total': _questions.length,
        'timestamp': FieldValue.serverTimestamp(),
      });
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
    } else {
      await _speak("Oops. $answer is incorrect.");
      setState(() {
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
      _speak("Great work! Your score is $score out of ${_questions.length}.");
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
        backgroundColor: Colors.orange,
      ),
      backgroundColor: const Color(0xFFFFF6ED),
      body: Center(
        child: finished
            ? _buildResultBox()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      "Question ${currentIndex + 1} of ${_questions.length}",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 20),
                    if (q['image'] != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.1),
                          border: Border.all(color: Colors.deepOrange, width: 3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset("images/new_images/${q['image']}", height: 160),
                      ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: DragTarget<String>(
                        builder: (context, candidate, rejected) => Container(
                          height: 60,
                          width: 240,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: wrongDrop ? Colors.red : Colors.deepOrange,
                                width: 3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            droppedAnswer ?? "Drop your answer here",
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange),
                          ),
                        ),
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
                              child: _buildOption(opt)),
                          childWhenDragging:
                              Opacity(opacity: 0.4, child: _buildOption(opt)),
                          child: _buildOption(opt),
                        );
                      }).toList(),
                    ),
                    if (droppedAnswer != null && !finished)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text("Next", style: TextStyle(fontSize: 22)),
                        ),
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

  Widget _buildResultBox() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("🎉 Well done!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text("🔁 Play Again", style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
