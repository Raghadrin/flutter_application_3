import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

class CompareQuantitiesGame extends StatefulWidget {
  const CompareQuantitiesGame({super.key});

  @override
  State<CompareQuantitiesGame> createState() => _CompareQuantitiesGameState();
}

class _CompareQuantitiesGameState extends State<CompareQuantitiesGame> {
  final FlutterTts tts = FlutterTts();
  int currentIndex = 0;
  int score = 0;
  bool isCorrect = false;
  bool showNext = false;

  final List<Map<String, dynamic>> _questions = [
    {
      "imageA": "images/new_images/group_3_apples.png",
      "imageB": "images/new_images/group_5_apples.png",
      "answer": "B",
      "question": "Which group has more apples?"
    },
    {
      "imageA": "images/new_images/group_4_balls.png",
      "imageB": "images/new_images/group_2_balls.png",
      "answer": "A",
      "question": "Which group has more balls?"
    },
    {
      "imageA": "images/new_images/group_5_stars.json",
      "imageB": "images/new_images/group_5_stars.json",
      "answer": "Yes",
      "question": "Do both groups have the same number of stars?",
      "options": ["Yes", "No"]
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
    _speak(_questions[currentIndex]['question']);
  }

  void _check(String selected) {
    final correct = _questions[currentIndex]['answer'];
    setState(() {
      isCorrect = selected == correct;
      showNext = true;
      if (isCorrect) score++;
    });

    _speak(isCorrect ? "Correct!" : "Try again!");
  }

  void _next() {
    if (currentIndex < _questions.length - 1) {
      setState(() {
        currentIndex++;
        isCorrect = false;
        showNext = false;
      });
      _speakCurrent();
    } else {
      _speak("Great job! You finished the game.");
      _showFinalDialog();
    }
  }

  void _resetGame() {
    setState(() {
      currentIndex = 0;
      score = 0;
      isCorrect = false;
      showNext = false;
    });
    _speakCurrent();
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
        title: const Text("🎉 Finished!", style: TextStyle(fontSize: 26)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Your Score: $score / ${_questions.length}", style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 10),
            Text(_getStars(score, _questions.length), style: const TextStyle(fontSize: 40)),
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

  Widget _buildMedia(String path) {
    if (path.endsWith('.json')) {
      return Lottie.asset(path, height: 120);
    } else {
      return Image.asset(path, height: 120);
    }
  }

  Widget _buildImage(String path, {required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              border: Border.all(color: Colors.deepOrange, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: _buildMedia(path),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Compare Quantities"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFF3E0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text("🏆 Score: $score", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              Container(
                width: screenWidth * 0.85,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Text(
                  q['question'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              // ✅ Conditional layout
              if (q['options'] != null)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildImage(q['imageA'], label: "A", onTap: () {}),
                        _buildImage(q['imageB'], label: "B", onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 16,
                      children: (q['options'] as List<String>).map((opt) {
                        return ElevatedButton(
                          onPressed: showNext ? null : () => _check(opt),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: opt == "Yes"
                                ? Colors.lightGreen.shade100
                                : Colors.pink.shade100,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(opt, style: const TextStyle(fontSize: 22)),
                        );
                      }).toList(),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImage(q['imageA'], label: "A", onTap: () => _check("A")),
                    _buildImage(q['imageB'], label: "B", onTap: () => _check("B")),
                  ],
                ),

              const SizedBox(height: 30),
              if (isCorrect)
                const Text("✅ Correct!", style: TextStyle(fontSize: 24, color: Colors.green)),
              if (showNext)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}
