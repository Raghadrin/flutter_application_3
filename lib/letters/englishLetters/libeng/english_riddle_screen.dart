import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class EnglishRiddleScreen extends StatefulWidget {
  const EnglishRiddleScreen({super.key});

  @override
  State<EnglishRiddleScreen> createState() => _EnglishRiddleScreenState();
}

class _EnglishRiddleScreenState extends State<EnglishRiddleScreen> {
  final FlutterTts flutterTts = FlutterTts();

  final List<Map<String, dynamic>> riddles = [
    {
      "riddle": "I appear in the sky during the day but not at night. What am I?",
      "answers": [
        {"text": "Shadow", "isCorrect": false},
        {"text": "Sun", "isCorrect": true},
        {"text": "Stars", "isCorrect": false},
      ]
    },
    {
      "riddle": "The more you take from me, the bigger I get. What am I?",
      "answers": [
        {"text": "A hole", "isCorrect": true},
        {"text": "Time", "isCorrect": false},
        {"text": "Memory", "isCorrect": false},
      ]
    },
    {
      "riddle": "I only move when hit. What am I?",
      "answers": [
        {"text": "Clock", "isCorrect": false},
        {"text": "Nail", "isCorrect": true},
        {"text": "Door", "isCorrect": false},
      ]
    },
    {
      "riddle": "What stays warm even if you put it in the fridge?",
      "answers": [
        {"text": "Pepper", "isCorrect": true},
        {"text": "Ice", "isCorrect": false},
        {"text": "Air", "isCorrect": false},
      ]
    },
    {
      "riddle": "What has teeth but doesn’t bite?",
      "answers": [
        {"text": "Comb", "isCorrect": true},
        {"text": "Brush", "isCorrect": false},
        {"text": "Knife", "isCorrect": false},
      ]
    },
    {
      "riddle": "I can hear without ears and speak without a mouth. What am I?",
      "answers": [
        {"text": "Phone", "isCorrect": true},
        {"text": "Radio", "isCorrect": false},
        {"text": "Robot", "isCorrect": false},
      ]
    },
  ];

  int currentRiddleIndex = 0;
  String? feedback;

  List<Map<String, dynamic>> get currentAnswers => riddles[currentRiddleIndex]["answers"];
  String get currentRiddle => riddles[currentRiddleIndex]["riddle"];

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.45);
    _speak(currentRiddle);
    currentAnswers.shuffle(Random());
  }

  Future<void> _speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  void _handleAnswer(Map<String, dynamic> answer) {
    setState(() {
      feedback = answer["isCorrect"] ? "✅ Correct!" : "❌ Wrong answer!";
    });
    _speak(answer["text"]);
  }

  void _nextRiddle() {
    setState(() {
      currentRiddleIndex = (currentRiddleIndex + 1) % riddles.length;
      feedback = null;
      currentAnswers.shuffle(Random());
    });
    _speak(currentRiddle);
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
        title: const Text("Riddles for Kids", style: TextStyle(fontSize: 20)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFA726),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("🔍 Riddle", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                currentRiddle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ...currentAnswers.map((answer) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ElevatedButton(
                      onPressed: () => _handleAnswer(answer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.orange, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        answer["text"],
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
              if (feedback != null)
                Text(
                  feedback!,
                  style: TextStyle(
                    fontSize: 18,
                    color: feedback!.contains("✅") ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _speak(currentRiddle),
                icon: const Icon(Icons.volume_up, size: 20),
                label: const Text("🔊 Hear the riddle again", style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _nextRiddle,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text("🔁 Next Riddle", style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
