import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AdvancedImageWordMatchScreen extends StatefulWidget {
  const AdvancedImageWordMatchScreen({super.key});

  @override
  State<AdvancedImageWordMatchScreen> createState() => _AdvancedImageWordMatchScreenState();
}

class _AdvancedImageWordMatchScreenState extends State<AdvancedImageWordMatchScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int score = 0;
  int attempts = 0;
  bool showScore = false;

  final List<Map<String, dynamic>> questions = [
    {
      "word": "شمس",
      "hint": "تظهر في النهار وتضيء الأرض",
      "options": [
        {"label": "شمس", "image": "☀️", "isCorrect": true},
        {"label": "قمر", "image": "🌙", "isCorrect": false},
        {"label": "نجمة", "image": "⭐", "isCorrect": false},
        {"label": "سحابة", "image": "☁️", "isCorrect": false},
      ]
    },
    {
      "word": "مكتبة",
      "hint": "مكان يحتوي على العديد من الكتب للقراءة",
      "options": [
        {"label": "مدرسة", "image": "🏫", "isCorrect": false},
        {"label": "مكتبة", "image": "📚", "isCorrect": true},
        {"label": "مستشفى", "image": "🏥", "isCorrect": false},
        {"label": "حديقة", "image": "🌳", "isCorrect": false},
      ]
    },
    {
      "word": "ساعة",
      "hint": "أداة نعرف بها الوقت",
      "options": [
        {"label": "هاتف", "image": "📱", "isCorrect": false},
        {"label": "ساعة", "image": "⌚", "isCorrect": true},
        {"label": "كمبيوتر", "image": "💻", "isCorrect": false},
        {"label": "مفتاح", "image": "🔑", "isCorrect": false},
      ]
    },
    {
      "word": "قطار",
      "hint": "وسيلة نقل تسير على القضبان",
      "options": [
        {"label": "سيارة", "image": "🚗", "isCorrect": false},
        {"label": "طائرة", "image": "✈️", "isCorrect": false},
        {"label": "قطار", "image": "🚆", "isCorrect": true},
        {"label": "دراجة", "image": "🚲", "isCorrect": false},
      ]
    },
  ];

  int currentQuestionIndex = 0;
  String? feedback;
  bool showHint = false;

  List<Map<String, dynamic>> get currentOptions => questions[currentQuestionIndex]["options"];
  String get currentWord => questions[currentQuestionIndex]["word"];
  String get currentHint => questions[currentQuestionIndex]["hint"];

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
      if (isCorrect) {
        score++;
      }
      attempts++;
      showHint = false;
    });
    flutterTts.speak(isCorrect ? "أحسنت! هذه هي الإجابة الصحيحة" : "للأسف هذه ليست الإجابة الصحيحة");
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        showScore = true;
      }
      feedback = null;
      currentOptions.shuffle();
      showHint = false;
    });
    if (!showScore) {
      _speakWord();
    }
  }

  void _resetGame() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      attempts = 0;
      feedback = null;
      showScore = false;
      currentOptions.shuffle();
    });
    _speakWord();
  }

  void _toggleHint() {
    setState(() {
      showHint = !showHint;
    });
    if (showHint) {
      flutterTts.speak("تلميح: $currentHint");
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (showScore) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF6ED),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "🎉 النتيجة النهائية 🎉",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              const SizedBox(height: 30),
              Text(
                "الإجابات الصحيحة: $score من ${questions.length}",
                style: const TextStyle(fontSize: 28, color: Colors.green),
              ),
              const SizedBox(height: 20),
              Text(
                "الدقة: ${(score / questions.length * 100).toStringAsFixed(1)}%",
                style: const TextStyle(fontSize: 24, color: Colors.blue),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _resetGame,
                icon: const Icon(Icons.refresh, size: 30),
                label: const Text("إعادة اللعبة", style: TextStyle(fontSize: 24)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        title: const Text("وين الكلمة؟ - المستوى المتقدم", 
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFA726),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, size: 30),
            onPressed: _toggleHint,
            tooltip: 'إظهار التلميح',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "اختر الصورة المناسبة لكلمة:",
                style: TextStyle(fontSize: 28, color: Colors.grey[700]),
              ),
              const SizedBox(height: 15),
              Text(
                currentWord,
                style: const TextStyle(fontSize: 42, color: Colors.orange, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              if (showHint)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Text(
                    "تلميح: $currentHint",
                    style: const TextStyle(fontSize: 24, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 40),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 30,
                runSpacing: 30,
                children: currentOptions.map((option) {
                  return GestureDetector(
                    onTap: feedback == null ? () => _handleTap(option["isCorrect"]) : null,
                    child: Container(
                      width: 150,
                      height: 150,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: feedback != null && option["isCorrect"] 
                            ? Colors.green 
                            : Colors.orange, 
                          width: 3),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(4, 4))
                        ],
                      ),
                      child: Text(
                        option["image"],
                        style: const TextStyle(fontSize: 60),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              if (feedback != null)
                Column(
                  children: [
                    Text(
                      feedback!,
                      style: TextStyle(
                        fontSize: 32,
                        color: feedback!.contains("✅") ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _nextQuestion,
                      icon: const Icon(Icons.arrow_forward, size: 30),
                      label: const Text("التالي", style: TextStyle(fontSize: 24)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                 ), ],
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _speakWord,
                    icon: const Icon(Icons.volume_up, size: 30),
                    label: const Text("كرر", style: TextStyle(fontSize: 22)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: _toggleHint,
                    icon: Icon(showHint ? Icons.visibility_off : Icons.visibility, size: 30),
                    label: Text(showHint ? "إخفاء التلميح" : "إظهار التلميح", style: const TextStyle(fontSize: 22)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "السؤال ${currentQuestionIndex + 1} من ${questions.length}",
                style: const TextStyle(fontSize: 22, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}