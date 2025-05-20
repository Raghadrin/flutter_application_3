import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AdvancedStoryCompleteScreen extends StatefulWidget {
  const AdvancedStoryCompleteScreen({super.key});

  @override
  State<AdvancedStoryCompleteScreen> createState() => _AdvancedStoryCompleteScreenState();
}

class _AdvancedStoryCompleteScreenState extends State<AdvancedStoryCompleteScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int score = 0;
  int attempts = 0;
  bool showScore = false;

  final List<Map<String, dynamic>> stories = [
    {
      "title": "A Trip to the Park",
      "start": "On a sunny day, Salma decided to go to the park near her house...",
      "hint": "What is the right behavior at the park?",
      "endings": [
        {"text": "She met her friends and played safely and happily.", "isCorrect": true},
        {"text": "She picked flowers and threw them on the ground.", "isCorrect": false},
        {"text": "She ate all her food and fell asleep under a tree.", "isCorrect": false},
        {"text": "She made fun of other kids in the park.", "isCorrect": false},
      ]
    },
    {
      "title": "The Homework Task",
      "start": "Khaled came back from school feeling tired, but he had homework to do...",
      "hint": "What is responsible behavior?",
      "endings": [
        {"text": "He focused and completed his homework carefully.", "isCorrect": true},
        {"text": "He closed his books and went to play soccer.", "isCorrect": false},
        {"text": "He asked his brother to do the homework for him.", "isCorrect": false},
        {"text": "He scribbled something quickly to finish it.", "isCorrect": false},
      ]
    },
    {
      "title": "The New Book",
      "start": "Laila received a new book as a gift from her aunt...",
      "hint": "How should we treat books?",
      "endings": [
        {"text": "She read it carefully and kept it clean and neat.", "isCorrect": true},
        {"text": "She tore out some pages to stick on the wall.", "isCorrect": false},
        {"text": "She forgot it under her bed and never opened it.", "isCorrect": false},
        {"text": "She gave it away before reading it.", "isCorrect": false},
      ]
    },
    {
      "title": "The Pet Animal",
      "start": "Yasser found a small kitten meowing at his door...",
      "hint": "How should we treat animals?",
      "endings": [
        {"text": "He kindly brought it food and water.", "isCorrect": true},
        {"text": "He shouted at it to go away.", "isCorrect": false},
        {"text": "He grabbed it roughly and threw it far.", "isCorrect": false},
        {"text": "He ignored it and walked away.", "isCorrect": false},
      ]
    },
  ];

  int currentStoryIndex = 0;
  String? feedback;
  bool showHint = false;

  List<Map<String, dynamic>> get currentEndings => stories[currentStoryIndex]["endings"];
  String get currentStart => stories[currentStoryIndex]["start"];
  String get currentTitle => stories[currentStoryIndex]["title"];
  String get currentHint => stories[currentStoryIndex]["hint"];

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.45);
    _speakText("$currentTitle. $currentStart");
    currentEndings.shuffle();
  }

  Future<void> _speakText(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  void _handleChoice(Map<String, dynamic> ending) {
    setState(() {
      feedback = ending["isCorrect"] ? "✅ Well done!" : "❌ Try again";
      if (ending["isCorrect"]) score++;
      attempts++;
      showHint = false;
    });
    _speakText(
      ending["isCorrect"]
          ? "Correct answer! ${ending["text"]}"
          : "Oops! Not the ideal answer. ${ending["text"]}",
    );
  }

  void _nextStory() {
    setState(() {
      if (currentStoryIndex < stories.length - 1) {
        currentStoryIndex++;
      } else {
        showScore = true;
      }
      feedback = null;
      currentEndings.shuffle();
      showHint = false;
    });
    if (!showScore) _speakText("$currentTitle. $currentStart");
  }

  void _resetGame() {
    setState(() {
      currentStoryIndex = 0;
      score = 0;
      attempts = 0;
      feedback = null;
      showScore = false;
      currentEndings.shuffle();
    });
    _speakText("$currentTitle. $currentStart");
  }

  void _toggleHint() {
    setState(() {
      showHint = !showHint;
    });
    if (showHint) _speakText("Hint: $currentHint");
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        title: const Text("Complete the Story", style: TextStyle(fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, size: 20),
            onPressed: _toggleHint,
          ),
        ],
      ),
      body: showScore
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("🎉 Final Score 🎉",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
                  const SizedBox(height: 20),
                  Text("Correct answers: $score of ${stories.length}",
                      style: const TextStyle(fontSize: 18, color: Colors.green)),
                  const SizedBox(height: 10),
                  Text("Accuracy: ${(score / stories.length * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(fontSize: 16, color: Colors.blue)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _resetGame,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text("Restart", style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(currentTitle,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Text(currentStart,
                        style: const TextStyle(fontSize: 16, color: Colors.brown),
                        textAlign: TextAlign.center),
                  ),
                  if (showHint) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Text("💡 $currentHint",
                          style: const TextStyle(fontSize: 14, color: Colors.blue),
                          textAlign: TextAlign.center),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text("Choose the ending:", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  ...currentEndings.map(
                    (ending) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ElevatedButton(
                        onPressed: feedback == null ? () => _handleChoice(ending) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: feedback != null && ending["isCorrect"] ? Colors.green : Colors.orange,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(ending["text"], style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                  ),
                  if (feedback != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      feedback!,
                      style: TextStyle(
                        fontSize: 16,
                        color: feedback!.contains("✅") ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _nextStory,
                      icon: const Icon(Icons.arrow_forward, size: 20),
                      label: const Text("Next", style: TextStyle(fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _speakText(currentStart),
                        icon: const Icon(Icons.volume_up, size: 20),
                        label: const Text("Listen", style: TextStyle(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _toggleHint,
                        icon: Icon(showHint ? Icons.visibility_off : Icons.visibility, size: 20),
                        label: Text(showHint ? "Hide Hint" : "Show Hint", style: const TextStyle(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text("Story ${currentStoryIndex + 1} of ${stories.length}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
    );
  }
}
