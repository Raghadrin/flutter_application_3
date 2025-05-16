import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ImageWordMatchScreen extends StatefulWidget {
  const ImageWordMatchScreen({super.key});

  @override
  State<ImageWordMatchScreen> createState() => _ImageWordMatchScreenState();
}

class _ImageWordMatchScreenState extends State<ImageWordMatchScreen> {
  final FlutterTts flutterTts = FlutterTts();

  final List<Map<String, dynamic>> questions = [
    {
      "word": "شمس",
      "options": [
        {"label": "شمس", "image": "☀️", "isCorrect": true},
        {"label": "قمر", "image": "🌙", "isCorrect": false},
        {"label": "شجرة", "image": "🌳", "isCorrect": false},
      ]
    },
    {
      "word": "تفاحة",
      "options": [
        {"label": "موز", "image": "🍌", "isCorrect": false},
        {"label": "تفاحة", "image": "🍎", "isCorrect": true},
        {"label": "برتقال", "image": "🍊", "isCorrect": false},
      ]
    },
    {
      "word": "كرة",
      "options": [
        {"label": "كرة", "image": "⚽", "isCorrect": true},
        {"label": "قلم", "image": "✏️", "isCorrect": false},
        {"label": "كتاب", "image": "📘", "isCorrect": false},
      ]
    },
  ];

  int currentQuestionIndex = 0;
  String? feedback;

  List<Map<String, dynamic>> get currentOptions =>
      questions[currentQuestionIndex]["options"];

  String get currentWord => questions[currentQuestionIndex]["word"];

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ar-SA");
    flutterTts.setSpeechRate(0.4);
    _speakWord();
    currentOptions.shuffle();
  }

  Future<void> _speakWord() async {
    await flutterTts.stop();
    await flutterTts.speak(currentWord);
  }

  void _handleTap(bool isCorrect) {
    setState(() {
      feedback = isCorrect ? "أحسنت! ✅" : "حاول مرة أخرى ❌";
    });
    flutterTts.speak(isCorrect ? "أحسنت!" : "حاول مرة أخرى");
  }

  void _nextQuestion() {
    setState(() {
      currentQuestionIndex = (currentQuestionIndex + 1) % questions.length;
      feedback = null;
      currentOptions.shuffle();
    });
    _speakWord();
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
        title: const Text("وين الكلمة؟", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFA726),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "اختر الصورة المناسبة لكلمة:",
                style: TextStyle(fontSize: 20, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                currentWord,
                style: const TextStyle(fontSize: 32, color: Colors.orange, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: currentOptions.map((option) {
                  return GestureDetector(
                    onTap: () => _handleTap(option["isCorrect"]),
                    child: Container(
                      width: 100,
                      height: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.orange, width: 2),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))
                        ],
                      ),
                      child: Text(
                        option["image"],
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              if (feedback != null)
                Text(
                  feedback!,
                  style: TextStyle(
                    fontSize: 24,
                    color: feedback!.contains("✅") ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _speakWord,
                icon: const Icon(Icons.volume_up),
                label: const Text("كرر الكلمة"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _nextQuestion,
                icon: const Icon(Icons.refresh),
                label: const Text("كلمة جديدة"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
