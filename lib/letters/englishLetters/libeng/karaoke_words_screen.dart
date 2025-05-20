import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FindCorrectWordScreen extends StatefulWidget {
  const FindCorrectWordScreen({super.key});

  @override
  State<FindCorrectWordScreen> createState() => _FindCorrectWordScreenState();
}

class _FindCorrectWordScreenState extends State<FindCorrectWordScreen> {
  final FlutterTts flutterTts = FlutterTts();

  final List<Map<String, dynamic>> questions = [
    {
      "word": "library",
      "options": ["libary", "liberry", "library", "librery", "libray", "librare"]
    },
    {
      "word": "responsibility",
      "options": ["responsbility", "resposibility", "responsibility", "responcibility", "responsibilty", "responcibilty"]
    },
    {
      "word": "exception",
      "options": ["exseption", "exception", "exaption", "excetion", "excepsion", "exsepsion"]
    },
    {
      "word": "professional",
      "options": ["profesional", "profetional", "professional", "profissional", "proffesional", "profechional"]
    },
    {
      "word": "strategy",
      "options": ["stradegy", "stratagy", "strategy", "stratejy", "strattegy", "stratijy"]
    },
  ];

  int currentIndex = 0;
  String? feedback;
  bool isAnswered = false;

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.4);
    _speakCurrentWord();
  }

  Future<void> _speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  Future<void> _speakCurrentWord() async {
    final word = questions[currentIndex]["word"];
    await _speak("Choose the correct spelling for: $word");
  }

  void checkAnswer(String selected) async {
    if (isAnswered) return;
    final correct = questions[currentIndex]["word"];
    setState(() {
      isAnswered = true;
      feedback = selected == correct
          ? "✅ Well done! That's correct."
          : "❌ The correct spelling is: $correct";
    });

    await _speak(feedback!);
    await Future.delayed(const Duration(milliseconds: 1600));
    setState(() {
      currentIndex = (currentIndex + 1) % questions.length;
      isAnswered = false;
      feedback = null;
    });

    _speakCurrentWord();
  }

  @override
  Widget build(BuildContext context) {
    final current = questions[currentIndex];
    final List<String> options = List<String>.from(current["options"]);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        title: const Text("Find the Correct Word", style: TextStyle(fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "🎧 Listen to the word and choose the correct spelling.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: options.map((word) {
                  return ElevatedButton(
                    onPressed: () => checkAnswer(word),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.orange, width: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      word,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              if (feedback != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: feedback!.contains("✅") ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    feedback!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: feedback!.contains("✅") ? Colors.green : Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _speakCurrentWord,
                icon: const Icon(Icons.volume_up, size: 20),
                label: const Text("🔊 Hear the word again", style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}
