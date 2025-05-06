import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:reorderables/reorderables.dart';

class ReorderWordLettersGame extends StatefulWidget {
  const ReorderWordLettersGame({super.key});

  @override
  _ReorderWordLettersGameState createState() => _ReorderWordLettersGameState();
}

class _ReorderWordLettersGameState extends State<ReorderWordLettersGame> {
  final FlutterTts tts = FlutterTts();

  final List<Map<String, dynamic>> questions = [
    {
      'word': 'APPLE',
    },
    {
      'word': 'DOG',
    },
    {
      'word': 'BALL',
    },
  ];

  int currentIndex = 0;
  List<String> shuffled = [];
  bool showResult = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  void _loadQuestion() {
    final word = questions[currentIndex]['word'];
    shuffled = word.split('')..shuffle();
    showResult = false;
    isCorrect = false;
    setState(() {});
  }

  void _checkAnswer() async {
    final word = questions[currentIndex]['word'];
    final userAnswer = shuffled.join();
    if (userAnswer == word) {
      isCorrect = true;
      await tts.speak("Well done! $word");
    } else {
      isCorrect = false;
      await tts.speak("Try again!");
    }
    setState(() => showResult = true);
  }

  void _nextQuestion() {
    currentIndex = (currentIndex + 1) % questions.length;
    _loadQuestion();
  }

  @override
  Widget build(BuildContext context) {
    final word = questions[currentIndex]['word'];

    return Scaffold(
      appBar: AppBar(title: Text("Reorder Letters")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Rearrange the letters to make the word:",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(word,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400)),
            SizedBox(height: 20),
            ReorderableWrap(
              needsLongPressDraggable: false,
              spacing: 10,
              runSpacing: 10,
              children: shuffled.map((letter) {
                return Container(
                  key: ValueKey(letter + shuffled.indexOf(letter).toString()),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(letter,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                );
              }).toList(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  final item = shuffled.removeAt(oldIndex);
                  shuffled.insert(newIndex, item);
                });
              },
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text("Check"),
            ),
            if (showResult)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  isCorrect ? "✅ Correct!" : "❌ Incorrect, try again.",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
              ),
            if (showResult && isCorrect)
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text("Next"),
              ),
          ],
        ),
      ),
    );
  }
}
