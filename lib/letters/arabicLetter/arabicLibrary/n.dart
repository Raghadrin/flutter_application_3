import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

class SunduqAlDadGame extends StatefulWidget {
  const SunduqAlDadGame({super.key});

  @override
  State<SunduqAlDadGame> createState() => _SunduqAlDadGameState();
}

class _SunduqAlDadGameState extends State<SunduqAlDadGame>
    with TickerProviderStateMixin {
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
        title:
            const Text("🎁 صندوق الضاد", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        toolbarHeight: 80,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (currentWord["animation"] != null)
                    Lottie.asset(
                      currentWord["animation"],
                      height: 200,
                    ),
                  const SizedBox(height: 12),
                  Text(
                    currentWord["word"],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.brown),
                  ),
                  const SizedBox(height: 30),
                  ...options.map((option) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ElevatedButton(
                          onPressed: showResult ? null : () => checkAnswer(option),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade200,
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                            minimumSize: const Size(300, 70),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 4,
                          ),
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
                  const SizedBox(height: 30),
                  if (showResult)
                    ScaleTransition(
                      scale: CurvedAnimation(
                          parent: _scaleController, curve: Curves.elasticOut),
                      child: Column(
                        children: [
                          Text(
                            correct ? "✅ أحسنت! الإجابة صحيحة" : "❌ خطأ! حاول مجددًا",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: correct ? Colors.green : Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentWord["desc"],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: loadNewWord,
                            icon: const Icon(Icons.refresh),
                            label: const Text("كلمة جديدة", style: TextStyle(fontSize: 24)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
