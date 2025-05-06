import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ReorderSentenceGame extends StatefulWidget {
  const ReorderSentenceGame({super.key});

  @override
  _ReorderSentenceGameState createState() => _ReorderSentenceGameState();
}

class _ReorderSentenceGameState extends State<ReorderSentenceGame> {
  final FlutterTts tts = FlutterTts();

  final List<Map<String, dynamic>> questions = [
    {
      'sentence': 'I like to read books',
    },
    {
      'sentence': 'The dog is running fast',
    },
    {
      'sentence': 'She has a red ball',
    },
  ];

  int current = 0;
  List<String> shuffled = [];
  bool showResult = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadSentence();
  }

  void _loadSentence() {
    final sentence = questions[current]['sentence'] as String;
    shuffled = sentence.split(' ')..shuffle();
    showResult = false;
    isCorrect = false;
    setState(() {});
  }

  void _checkAnswer() async {
    final correctSentence = questions[current]['sentence'];
    final userSentence = shuffled.join(' ');
    isCorrect = (userSentence == correctSentence);
    showResult = true;

    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.speak(isCorrect ? "Correct!" : "Try again!");
  }

  void _nextQuestion() {
    setState(() {
      current = (current + 1) % questions.length;
    });
    _loadSentence();
  }

  @override
  Widget build(BuildContext context) {
    final correctSentence = questions[current]['sentence'];

    return Scaffold(
      appBar: AppBar(title: Text("Reorder the Sentence")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Arrange the words to form a correct sentence:",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ReorderableWrap(
              needsLongPressDraggable: false,
              spacing: 12,
              runSpacing: 12,
              children: shuffled.map((word) {
                return Chip(
                  key: ValueKey(word + shuffled.indexOf(word).toString()),
                  label: Text(word,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.orange.shade100,
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
                  isCorrect ? "✅ Correct!" : "❌ Incorrect. Try again!",
                  style: TextStyle(
                    fontSize: 20,
                    color: isCorrect ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (showResult && isCorrect)
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text("Next"),
              ),
            SizedBox(height: 30),
            Text("Hint: $correctSentence",
                style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}
