import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SunduqAlDadGame extends StatefulWidget {
  const SunduqAlDadGame({super.key});

  @override
  State<SunduqAlDadGame> createState() => _SunduqAlDadGameState();
}

class _SunduqAlDadGameState extends State<SunduqAlDadGame> {
  final FlutterTts tts = FlutterTts();
  final Random random = Random();
  bool showResult = false;
  bool correct = false;

  late Map<String, dynamic> currentWord;
  late List<String> options;

  final List<Map<String, dynamic>> words = [
    {
      "word": "مروءة 🕊️",
      "desc": "أن تساعد دون أن تنتظر شيئًا في المقابل.",
      "choices": ["قوة الجسم", "كرم النفس", "صوت مرتفع"],
      "answer": "كرم النفس"
    },
    {
      "word": "سكينة 🌙",
      "desc": "راحة للقلب وصفاء للفكر.",
      "choices": ["ضوضاء", "هدوء داخلي", "سرعة الحركة"],
      "answer": "هدوء داخلي"
    },
    {
      "word": "نُبل 👑",
      "desc": "كرم ولُطف حتى في أصعب الظروف.",
      "choices": ["قلة المال", "الكرم واللطف", "سرعة الجري"],
      "answer": "الكرم واللطف"
    },
    {
      "word": "جَسارة 🛡️",
      "desc": "مواجهة الصعب بثبات دون تردد.",
      "choices": ["الخوف", "الشجاعة", "التردد"],
      "answer": "الشجاعة"
    },
    {
      "word": "بصيرة 👁️",
      "desc": "رؤية بنور العقل لا الجسد فقط.",
      "choices": ["النظر", "الرؤية بالعقل", "السمع"],
      "answer": "الرؤية بالعقل"
    },
  ];

  @override
  void initState() {
    super.initState();
    tts.setLanguage("ar-SA");
    tts.setSpeechRate(0.45);
    loadNewWord();
  }

  void loadNewWord() {
    final newWord = words[random.nextInt(words.length)];
    setState(() {
      currentWord = newWord;
      options = List<String>.from(newWord["choices"] as List)..shuffle();
      showResult = false;
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text("🎁 صندوق الضاد",
            style: TextStyle(fontSize: 28, fontFamily: 'Amiri')),
        backgroundColor: Colors.orange,
        centerTitle: true,
        toolbarHeight: 80,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentWord["word"],
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ...options.map((option) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                      onPressed: showResult ? null : () => checkAnswer(option),
                      child: Text(option,
                          style: const TextStyle(fontSize: 26)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 30),
                        minimumSize: const Size(280, 70),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  )),
              const SizedBox(height: 30),
              if (showResult)
                Column(
                  children: [
                    Text(
                      correct
                          ? "✅ أحسنت! الإجابة صحيحة"
                          : "❌ خطأ! حاول مجددًا",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: correct ? Colors.green : Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentWord["desc"],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 22, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: loadNewWord,
                      child: const Text("🔁 كلمة جديدة",
                          style: TextStyle(fontSize: 24)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 30),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
