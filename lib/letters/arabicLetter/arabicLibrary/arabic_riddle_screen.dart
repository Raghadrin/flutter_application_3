import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ArabicRiddleScreen extends StatefulWidget {
  const ArabicRiddleScreen({super.key});

  @override
  State<ArabicRiddleScreen> createState() => _ArabicRiddleScreenState();
}

class _ArabicRiddleScreenState extends State<ArabicRiddleScreen> {
  final FlutterTts flutterTts = FlutterTts();

  final List<Map<String, dynamic>> riddles = [
    {
      "riddle": "أنا شيء تراه في النهار ولا تراه في الليل، من أكون؟",
      "answers": [
        {"text": "الظل", "isCorrect": false},
        {"text": "الشمس", "isCorrect": true},
        {"text": "النجوم", "isCorrect": false},
      ]
    },
    {
      "riddle": "ما هو الشيء الذي كلما أخذت منه كبر؟",
      "answers": [
        {"text": "الحفرة", "isCorrect": true},
        {"text": "الوقت", "isCorrect": false},
        {"text": "الذاكرة", "isCorrect": false},
      ]
    },
    {
      "riddle": "ما هو الشيء الذي لا يمشي إلا بالضرب؟",
      "answers": [
        {"text": "الساعة", "isCorrect": false},
        {"text": "المسمار", "isCorrect": true},
        {"text": "الباب", "isCorrect": false},
      ]
    },
  ];

  int currentRiddleIndex = 0;
  String? feedback;

  List<Map<String, dynamic>> get currentAnswers =>
      riddles[currentRiddleIndex]["answers"];

  String get currentRiddle => riddles[currentRiddleIndex]["riddle"];

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ar-SA");
    flutterTts.setSpeechRate(0.45);
    _speak(currentRiddle);
    currentAnswers.shuffle();
  }

  Future<void> _speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  void _handleAnswer(Map<String, dynamic> answer) {
    setState(() {
      feedback = answer["isCorrect"] ? "إجابة صحيحة ✅" : "إجابة خاطئة ❌";
    });
    _speak(answer["text"]);
  }

  void _nextRiddle() {
    setState(() {
      currentRiddleIndex = (currentRiddleIndex + 1) % riddles.length;
      feedback = null;
      currentAnswers.shuffle();
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
        title: const Text("كلمة السر", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFA726),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("اللغز:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Text(
                currentRiddle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 22,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ...currentAnswers.map((answer) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      onPressed: () => _handleAnswer(answer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.orange, width: 2),
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        answer["text"],
                        style: const TextStyle(
                            fontSize: 18, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )),
              const SizedBox(height: 30),
              if (feedback != null)
                Text(
                  feedback!,
                  style: TextStyle(
                    fontSize: 22,
                    color:
                        feedback!.contains("✅") ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _speak(currentRiddle),
                icon: const Icon(Icons.volume_up),
                label: const Text("أعد سماع اللغز"),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _nextRiddle,
                icon: const Icon(Icons.refresh),
                label: const Text("لغز جديد"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
