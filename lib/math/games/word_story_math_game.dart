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
  bool finished = false;
  int currentSpokenWord = -1;
  String? droppedAnswer;
  bool wrongDrop = false;

  final List<Map<String, dynamic>> _questions = [
    {
      "question":
          "Lina started with 12 pencils. She gave 3 to her friend, then bought 2 more at the store. How many pencils does she have now?",
      "options": ["11", "10", "12"],
      "answer": "11",
      "hint": "Start with 12, subtract 3, then add 2.",
      "image": "lina_pencils.png"
    },
    {
      "question":
          "Jad collected 5 trading cards, then found 6 more near his desk. Later, he lost 2 while playing. How many cards does he have now?",
      "options": ["9", "10", "11"],
      "answer": "9",
      "hint": "Add 5 and 6, then subtract 2.",
      "image": "jad_cards.png"
    },
    {
      "question":
          "Sara baked 8 cookies in the morning. She ate 2 after lunch and gave 3 to her neighbor. How many cookies are left on the tray?",
      "options": ["3", "5", "4"],
      "answer": "3",
      "hint": "8 cookies - 2 eaten - 3 given away.",
      "image": "sara_cookies.png"
    },
    {
      "question":
          "Tom picked 7 apples from one tree and 4 more from another. While walking home, he accidentally dropped 2. How many apples does he still have?",
      "options": ["9", "11", "8"],
      "answer": "9",
      "hint": "7 + 4 = 11, then subtract 2.",
      "image": "tom_apples.png"
    },
    {
      "question":
          "A box had 10 colorful markers. Four were used up by the end of the week, but mom bought 3 new ones. How many markers are there now?",
      "options": ["9", "13", "10"],
      "answer": "9",
      "hint": "10 - 4 + 3 equals what?",
      "image": "box_markers.png"
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
    _speakStoryKaraoke();
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
          .collection('game3')
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

  Future<void> _speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45);
    await tts.speak(text);
  }

  Future<void> _speakStoryKaraoke() async {
    final words = _questions[currentIndex]['question'].split(' ');
    for (int i = 0; i < words.length; i++) {
      setState(() => currentSpokenWord = i);
      await _speak(words[i]);
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    setState(() => currentSpokenWord = -1);
  }

  void _checkDroppedAnswer(String answer) async {
    setState(() {
      droppedAnswer = answer;
      wrongDrop = false;
    });

    final correct = _questions[currentIndex]['answer'];
    if (answer == correct) {
      score++;
      await _speak("Correct. $answer is the right answer.");
      await Future.delayed(const Duration(seconds: 1));
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
        currentSpokenWord = -1;
        droppedAnswer = null;
      });
      _speakStoryKaraoke();
    } else {
      setState(() => finished = true);
      _speak("You finished all the stories. Well done!");
      await _saveScore(score);
    }
  }

  String _getStars(int score, int total) {
    double ratio = score / total;
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
          title: const Text("Story Math Game"), backgroundColor: Colors.orange),
      backgroundColor: const Color(0xFFFFF6ED),
      body: Center(
        child: finished
            ? _buildResultBox()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (wrongDrop)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text("Try again!",
                            style: TextStyle(fontSize: 22, color: Colors.red)),
                      ),
                    _buildQuestionWords(words),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _speak(q['hint']),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange),
                      child: const Text("Hint", style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 20),
                    if (q['image'] != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: Colors.deepOrange, width: 3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset("images/new_images/${q['image']}",
                              height: 160),
                        ),
                      ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) => Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child),
                      child: DragTarget<String>(
                        builder: (context, candidateData, rejectedData) =>
                            Container(
                          height: 60,
                          width: 200,
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
                            droppedAnswer ?? "Drop your answer here",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22),
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
                              child: _buildOption(opt)),
                          childWhenDragging:
                              Opacity(opacity: 0.4, child: _buildOption(opt)),
                          child: _buildOption(opt),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildQuestionWords(List<String> words) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepOrange, width: 2),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: List.generate(words.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              words[i],
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color:
                    i == currentSpokenWord ? Colors.deepOrange : Colors.black,
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
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("🎉 You finished!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text("Score: $score / ${_questions.length}",
              style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 10),
          Text(_getStars(score, _questions.length),
              style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Back", style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
