import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TwoStepWordProblemGame extends StatefulWidget {
  const TwoStepWordProblemGame({super.key});

  @override
  State<TwoStepWordProblemGame> createState() => _TwoStepWordProblemGameState();
}

class _TwoStepWordProblemGameState extends State<TwoStepWordProblemGame> {
  final FlutterTts tts = FlutterTts();
  int currentIndex = 0;
  int score = 0;
  bool finished = false;
  bool isCorrect = false;
  bool showNext = false;
  int currentSpokenWord = -1;

  final List<Map<String, dynamic>> _questions = [
    {
      "question":
          "Sara had 3 apples. Her mom gave her 4 more. Then she ate 2. How many apples now?",
      "image": "sara_apples.png",
      "options": ["5", "6", "7"],
      "answer": "5",
    },
    {
      "question":
          "Mona picked 6 flowers. She gave 2 to her friend and then picked 3 more. How many now?",
      "image": "Mona_flowers.png",
      "options": ["7", "8", "9"],
      "answer": "7",
    },
    {
      "question":
          "Ali had 10 balloons. 4 flew away and then he got 2 more. How many balloons now?",
      "image": "ali_balloons.png",
      "options": ["8", "7", "6"],
      "answer": "8",
    },
  ];

  @override
  void initState() {
    super.initState();
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
          .doc('math2')
          .collection('game4')
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
    await tts.setSpeechRate(0.2);
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

  void _check(String value) {
    final correct = _questions[currentIndex]['answer'];
    setState(() {
      isCorrect = (value == correct);
      showNext = isCorrect;
      if (isCorrect) score++;
    });
    _speak(isCorrect ? "That's right!" : "Oops, try again!");
  }

  Future<void> _next() async {
    if (currentIndex < _questions.length - 1) {
      setState(() {
        currentIndex++;
        isCorrect = false;
        showNext = false;
      });
      _speakStoryKaraoke();
    } else {
      setState(() => finished = true);
      _speak("Great job! You finished all the word problems.");
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
        title: const Text("Two-Step Word Problem"),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: const Color(0xFFFFF6ED),
      body: Center(
        child: finished
            ? Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("🎉 You finished!",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text("Score: $score / ${_questions.length}",
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Text(_getStars(score, _questions.length),
                        style: const TextStyle(fontSize: 40)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Back", style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            child: Text(
                              words[i],
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
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
                    ),
                    const SizedBox(height: 20),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child:
                              Text(opt, style: const TextStyle(fontSize: 24)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    if (isCorrect)
                      const Text("✅ Correct!",
                          style: TextStyle(fontSize: 22, color: Colors.green)),
                    if (showNext)
                      ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber),
                        child:
                            const Text("Next", style: TextStyle(fontSize: 22)),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
