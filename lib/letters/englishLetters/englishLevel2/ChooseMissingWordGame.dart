import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChooseMissingWordGame extends StatefulWidget {
  const ChooseMissingWordGame({super.key});

  @override
  _ChooseMissingWordGameState createState() => _ChooseMissingWordGameState();
}

class _ChooseMissingWordGameState extends State<ChooseMissingWordGame> {
  final FlutterTts tts = FlutterTts();

  final List<Map<String, dynamic>> questions = [
    {
      'sentence': 'She ___ a book.',
      'answer': 'has',
      'options': ['play', 'has', 'eat']
    },
    {
      'sentence': 'They ___ soccer every day.',
      'answer': 'play',
      'options': ['walk', 'play', 'run']
    },
    {
      'sentence': 'I ___ to school.',
      'answer': 'go',
      'options': ['fly', 'eat', 'go']
    },
  ];

  int currentIndex = 0;
  String? selected;
  bool showResult = false;

  @override
  void initState() {
    super.initState();
    _speakSentence();
  }

  Future<void> _speakSentence() async {
    String sentence =
        questions[currentIndex]['sentence'].replaceAll("___", "blank");
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.setPitch(1.0);
    await tts.speak(sentence);
  }

  void _checkAnswer(String word) async {
    setState(() {
      selected = word;
      showResult = true;
    });

    await tts.speak(
        word == questions[currentIndex]['answer'] ? "Correct!" : "Try again!");
  }

  void _nextQuestion() {
    setState(() {
      currentIndex = (currentIndex + 1) % questions.length;
      selected = null;
      showResult = false;
    });
    _speakSentence();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Choose Missing Word")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Choose the word that completes the sentence:",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(
              question['sentence'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            ElevatedButton.icon(
              onPressed: _speakSentence,
              icon: Icon(Icons.volume_up),
              label: Text("Play Sentence"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent),
            ),
            SizedBox(height: 30),
            ...question['options'].map<Widget>((word) {
              bool isCorrect = word == question['answer'];
              bool isSelected = selected == word;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: showResult ? null : () => _checkAnswer(word),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showResult
                        ? (isSelected
                            ? (isCorrect ? Colors.green : Colors.red)
                            : Colors.blue.shade100)
                        : Colors.blue.shade100,
                  ),
                  child: Text(word, style: TextStyle(fontSize: 18)),
                ),
              );
            }).toList(),
            if (showResult)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Next"),
                ),
              )
          ],
        ),
      ),
    );
  }
}
