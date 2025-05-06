import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DragWordToSentenceGame extends StatefulWidget {
  const DragWordToSentenceGame({super.key});

  @override
  _DragWordToSentenceGameState createState() => _DragWordToSentenceGameState();
}

class _DragWordToSentenceGameState extends State<DragWordToSentenceGame> {
  final FlutterTts tts = FlutterTts();

  final List<Map<String, dynamic>> questions = [
    {
      'sentence': 'The ____ is red.',
      'target': 'apple',
      'options': ['apple', 'ball', 'car']
    },
    {
      'sentence': 'I see a ____ in the sky.',
      'target': 'bird',
      'options': ['bird', 'fish', 'frog']
    },
  ];

  int currentIndex = 0;
  String? droppedWord;
  bool? isCorrect;

  @override
  void initState() {
    super.initState();
    _speakSentence();
  }

  Future<void> _speakSentence() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts
        .speak(questions[currentIndex]['sentence'].replaceAll("____", "blank"));
  }

  Future<void> _speakWord(String word) async {
    await tts.speak(word);
  }

  void checkAnswer(String word) async {
    setState(() {
      droppedWord = word;
      isCorrect = word == questions[currentIndex]['target'];
    });

    await tts.speak(isCorrect! ? "Correct!" : "Try again!");
  }

  void nextQuestion() {
    setState(() {
      currentIndex = (currentIndex + 1) % questions.length;
      droppedWord = null;
      isCorrect = null;
    });
    _speakSentence();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];
    final baseSentence = question['sentence'];

    return Scaffold(
      appBar: AppBar(title: Text("Drag Word to Sentence")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Drag the correct word to complete the sentence",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            DragTarget<String>(
              builder: (context, candidateData, rejectedData) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    droppedWord != null
                        ? baseSentence.replaceAll("____", droppedWord!)
                        : baseSentence,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              onAcceptWithDetails: (word) {
                checkAnswer(word as String);
              },
            ),
            SizedBox(height: 40),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: question['options'].map<Widget>((word) {
                return Draggable<String>(
                  data: word,
                  feedback: Material(
                    child: Chip(
                      label: Text(word, style: TextStyle(fontSize: 20)),
                      backgroundColor: Colors.blue.shade300,
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: Chip(
                      label: Text(word, style: TextStyle(fontSize: 20)),
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () => _speakWord(word),
                    child: Chip(
                      label: Text(word, style: TextStyle(fontSize: 20)),
                      backgroundColor: Colors.blue.shade100,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 30),
            if (isCorrect != null)
              Text(
                isCorrect! ? "✅ Correct!" : "❌ Incorrect!",
                style: TextStyle(
                  fontSize: 22,
                  color: isCorrect! ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (isCorrect != null)
              ElevatedButton(
                onPressed: nextQuestion,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text("Next"),
              ),
          ],
        ),
      ),
    );
  }
}
