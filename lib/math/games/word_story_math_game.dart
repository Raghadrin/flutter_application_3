import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WordStoryMathGame extends StatefulWidget {
  const WordStoryMathGame({super.key});

  @override
  State<WordStoryMathGame> createState() => _WordStoryMathGameState();
}

class _WordStoryMathGameState extends State<WordStoryMathGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final FlutterTts tts = FlutterTts();
  int currentIndex = 0;
  int score = 0;
  int currentSpokenWord = -1;
  String? droppedAnswer;
  bool wrongDrop = false;
  bool finished = false;

  final List<Map<String, dynamic>> _questions = [
    {
      "question": "Lina had 12 pencils. She gave 3 away, then bought 2. How many now?",
      "options": ["11", "10", "12"],
      "answer": "11",
      "hint": "12 - 3 + 2",
      "image": "lina_pencils.png"
    },
    {
      "question": "Jad had 5 cards, found 6, lost 2. How many now?",
      "options": ["9", "10", "11"],
      "answer": "9",
      "hint": "5 + 6 - 2",
      "image": "jad_cards.png"
    },
    {
      "question": "Sara baked 8 cookies, ate 2, gave away 3. What's left?",
      "options": ["3", "5", "4"],
      "answer": "3",
      "hint": "8 - 2 - 3",
      "image": "sara_cookies.png"
    },
    {
      "question": "Tom picked 7 apples and 4 more. Dropped 2. How many now?",
      "options": ["9", "11", "8"],
      "answer": "9",
      "hint": "7 + 4 - 2",
      "image": "tom_apples.png"
    },
    {
      "question": "10 markers - 4 used + 3 bought. How many now?",
      "options": ["9", "13", "10"],
      "answer": "9",
      "hint": "10 - 4 + 3",
      "image": "box_markers.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
    _speakStoryKaraoke();
  }

  Future<void> _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.5);
    await tts.speak(text);
  }

  Future<void> _speakStoryKaraoke() async {
    final words = _questions[currentIndex]['question'].split(' ');
    for (int i = 0; i < words.length; i++) {
      setState(() => currentSpokenWord = i);
      await _speak(words[i]);
      await Future.delayed(const Duration(milliseconds: 600));
    }
    setState(() => currentSpokenWord = -1);
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
      final childId = childrenSnapshot.docs.firstOrNull?.id;
      if (childId == null) return;

      await FirebaseFirestore.instance
          .collection('parents')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('math')
          .doc('math3')
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

  void _checkDroppedAnswer(String answer) async {
    final correct = _questions[currentIndex]['answer'];
    setState(() {
      droppedAnswer = answer;
      wrongDrop = false;
    });

    if (answer == correct) {
      setState(() => score += 10);
      await _speak("Correct! $answer is right.");
    } else {
      await _speak("Oops. Try again.");
      setState(() {
        droppedAnswer = null;
        wrongDrop = true;
        _shakeController.forward(from: 0);
      });
    }
  }

  void _next() async {
    if (currentIndex < _questions.length - 1) {
      setState(() {
        currentIndex++;
        droppedAnswer = null;
        currentSpokenWord = -1;
        wrongDrop = false;
      });
      await _speakStoryKaraoke();
    } else {
      setState(() => finished = true);
      await _speak("Great job! Final score: $score.");
      await _saveScore();
    }
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
    final words = q['question'].split(' ');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Story Math Game"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFF6ED),
      body: Center(
        child: finished
            ? _buildResultBox()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Question ${currentIndex + 1} of ${_questions.length}",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange),
                    ),
                    const SizedBox(height: 16),
                    if (wrongDrop)
                      const Text("Try again!",
                          style: TextStyle(fontSize: 20, color: Colors.red)),
                    const SizedBox(height: 16),
                    _buildStoryBox(words),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _speak(q['hint']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade200,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Hint", style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 24),
                    if (q['image'] != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          border: Border.all(
                              color: Colors.orange.withOpacity(0.7), width: 4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          "images/new_images/${q['image']}",
                          height: 160,
                        ),
                      ),
                    const SizedBox(height: 24),
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) => Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child),
                      child: DragTarget<String>(
                        onAccept: (value) => _checkDroppedAnswer(value),
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            width: 220,
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: wrongDrop
                                      ? Colors.red
                                      : Colors.deepOrange,
                                  width: 3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              droppedAnswer ?? "Drop answer here",
                              style: const TextStyle(fontSize: 20),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      children: (q['options'] as List<String>).map((opt) {
                        return Draggable<String>(
                          data: opt,
                          feedback: Material(
                              color: Colors.transparent,
                              child: _buildOption(opt)),
                          childWhenDragging: Opacity(
                              opacity: 0.5, child: _buildOption(opt)),
                          child: _buildOption(opt),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _next,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Next", style: TextStyle(fontSize: 20)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent.shade100,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 14),
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

  Widget _buildStoryBox(List<String> words) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        border: Border.all(color: Colors.deepOrange),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: List.generate(words.length, (i) {
          return Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              words[i],
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: i == currentSpokenWord
                    ? Colors.deepOrange
                    : Colors.black,
                backgroundColor: i == currentSpokenWord
                    ? Colors.orange.withOpacity(0.4)
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOption(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.shade100,
        border: Border.all(
            color: wrongDrop ? Colors.red : Colors.deepOrange, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildResultBox() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🎉 Great job!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text("Score: $score / ${_questions.length * 10}",
                style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 10),
            Text(_getStars(score, _questions.length),
                style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back", style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
