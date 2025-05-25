import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

class SunduqAlDadGame extends StatefulWidget {
  const SunduqAlDadGame({super.key});

  @override
  State<SunduqAlDadGame> createState() => _SunduqAlDadGameState();
}

class _SunduqAlDadGameState extends State<SunduqAlDadGame> with TickerProviderStateMixin {
  final FlutterTts tts = FlutterTts();
  final Random random = Random();
  bool showResult = false;
  bool correct = false;

  late Map<String, dynamic> currentWord;
  late List<String> options;
  late AnimationController _scaleController;

  final List<Map<String, dynamic>> words = [
    {
      "word": "مروءة 🕊️",
      "desc": "أن تساعد دون أن تنتظر شيئًا في المقابل.",
      "choices": ["قوة الجسم", "كرم النفس", "صوت مرتفع"],
      "answer": "كرم النفس",
      "animation": "images/Helping.json",
    },
    {
      "word": "سكينة 🌙",
      "desc": "راحة للقلب وصفاء للفكر.",
      "choices": ["ضوضاء", "هدوء داخلي", "سرعة الحركة"],
      "answer": "هدوء داخلي",
      "animation": "images/Night.json",
    },
    {
      "word": "نُبل 👑",
      "desc": "كرم ولُطف حتى في أصعب الظروف.",
      "choices": ["قلة المال", "الكرم واللطف", "سرعة الجري"],
      "answer": "الكرم واللطف",
      "animation": "images/Generous.json",
    },
    {
      "word": "جَسارة 🛡️",
      "desc": "مواجهة الصعب بثبات دون تردد.",
      "choices": ["الخوف", "الشجاعة", "التردد"],
      "answer": "الشجاعة",
      "animation": "images/Brave-monkey.json",
    },
    {
      "word": "بصيرة 👁️",
      "desc": "رؤية بنور العقل لا الجسد فقط.",
      "choices": ["النظر", "الرؤية بالعقل", "السمع"],
      "answer": "الرؤية بالعقل",
      "animation": "images/Eyes.json",
    },
  ];

  @override
  void initState() {
    super.initState();
    tts.setLanguage("ar-SA");
    tts.setSpeechRate(0.45);
    _scaleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    loadNewWord();
  }

  void loadNewWord() {
    final newWord = words[random.nextInt(words.length)];
    setState(() {
      currentWord = newWord;
      options = List<String>.from(newWord["choices"] as List)..shuffle();
      showResult = false;
    });
    _scaleController.forward(from: 0);
  }

  void checkAnswer(String selected) {
    final isCorrect = selected == currentWord["answer"];
    setState(() {
      correct = isCorrect;
      showResult = true;
    });
    tts.speak("${currentWord["word"]}. ${currentWord["desc"]}");
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text("🎁 صندوق الضاد", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        toolbarHeight: 70,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepOrange, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                child: Lottie.asset(
                  currentWord["animation"],
                  height: 150,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentWord["word"],
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.brown),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.volume_up, color: Colors.deepOrange, size: 30),
                            onPressed: () {
                              tts.speak(currentWord["word"]);
                            },
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          tts.speak(currentWord["desc"]);
                        },
                        icon: const Icon(Icons.record_voice_over, color: Colors.orange),
                        label: const Text("استمع للشرح", style: TextStyle(fontSize: 18, color: Colors.orange)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...options.map((option) => Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: ElevatedButton(
                              onPressed: showResult ? null : () => checkAnswer(option),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade200,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                minimumSize: const Size(260, 50),
                              ),
                              child: Text(option, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (showResult)
                ScaleTransition(
                  scale: CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          correct ? "✅ أحسنت! الإجابة صحيحة" : "❌ خطأ! حاول مجددًا",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: correct ? Colors.green : Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          currentWord["desc"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: loadNewWord,
                          icon: const Icon(Icons.refresh),
                          label: const Text("كلمة جديدة", style: TextStyle(fontSize: 20)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
