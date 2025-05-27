import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TwoStepWordProblemGame extends StatefulWidget {
  const TwoStepWordProblemGame({super.key});

  @override
  State<TwoStepWordProblemGame> createState() => _TwoStepWordProblemGameState();
}

class _TwoStepWordProblemGameState extends State<TwoStepWordProblemGame>
    with SingleTickerProviderStateMixin {
  final FlutterTts tts = FlutterTts();
  int currentIndex = 0;
  int score = 0;
  bool finished = false;
  bool wrongDrop = false;
  String? droppedAnswer;
  int currentSpokenWord = -1;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final List<Map<String, dynamic>> _questions = [
    {
      "question": "Sara had 3 apples. Her mom gave her 4 more. Then she ate 2. How many apples now?",
      "image": "sara_apples.png",
      "options": ["5", "6", "7"],
      "answer": "5",
      "hint": "3 + 4 - 2"
    },
    {
      "question": "Mona picked 6 flowers. She gave 2 to her friend and then picked 3 more. How many now?",
      "image": "mona_flowers.png",
      "options": ["7", "8", "9"],
      "answer": "7",
      "hint": "6 - 2 + 3"
    },
    {
      "question": "Ali had 10 balloons. 4 flew away and then he got 2 more. How many balloons now?",
      "image": "ali_balloons.png",
      "options": ["8", "7", "6"],
      "answer": "8",
      "hint": "10 - 4 + 2"
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
    await tts.setPitch(1.0);
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

  void _checkDroppedAnswer(String value) async {
    final correct = _questions[currentIndex]['answer'];
    setState(() {
      droppedAnswer = value;
      wrongDrop = false;
    });

    if (value == correct) {
      setState(() => score += 10);
      await _speak("Correct! $value is right.");
    } else {
      await _speak("Oops! Try again.");
      setState(() {
        droppedAnswer = null;
        wrongDrop = true;
        _shakeController.forward(from: 0);
      });
    }
  }

  void _next() {
    if (currentIndex < _questions.length - 1) {
      setState(() {
        currentIndex++;
        droppedAnswer = null;
        wrongDrop = false;
      });
      _speakStoryKaraoke();
    } else {
      setState(() => finished = true);
      _speak("Great job! You finished all the questions.");
      _saveScore();
    }
  }

  Future<void> _saveScore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final parentId = user.uid;
    final childrenSnapshot = await FirebaseFirestore.instance
        .collection('parents')
        .doc(parentId)
        .collection('children')
        .get();
    final childId = childrenSnapshot.docs.isNotEmpty
        ? childrenSnapshot.docs.first.id
        : null;
    if (childId == null) return;

    await FirebaseFirestore.instance
        .collection('parents')
        .doc(parentId)
        .collection('children')
        .doc(childId)
        .collection('math')
        .doc('math2')
        .collection('game4')
        .add({
      'score': score,
      'total': _questions.length * 10,
      'percentage': score / (_questions.length * 10),
      'correct': score ~/ 10,
      'wrong': _questions.length - (score ~/ 10),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[currentIndex];
    final words = q['question'].split(' ');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Two-Step Word Problem"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFF6ED),
      body: finished
          ? _buildFinalScore()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    "Question ${currentIndex + 1} of ${_questions.length}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStoryWords(words),
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
                  const SizedBox(height: 20),
                  if (q['image'] != null)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        border: Border.all(
                            color: Colors.orange.withOpacity(0.7), width: 4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Image.asset("images/new_images/${q['image']}",
                          height: 160),
                    ),
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
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 20,
                    alignment: WrapAlignment.center,
                    children: (q["options"] as List<String>).map((opt) {
                      return Draggable<String>(
                        data: opt,
                        feedback: Material(
                          color: Colors.transparent,
                          child: _buildOption(opt),
                        ),
                        childWhenDragging:
                            Opacity(opacity: 0.5, child: _buildOption(opt)),
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
    );
  }

  Widget _buildStoryWords(List<String> words) {
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

  Widget _buildFinalScore() {
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

  String _getStars(int score, int total) {
    double ratio = score / (total * 10);
    if (ratio == 1.0) return "🌟🌟🌟";
    if (ratio >= 0.66) return "🌟🌟";
    if (ratio >= 0.33) return "🌟";
    return "⭐";
  }
}
