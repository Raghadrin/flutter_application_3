import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ArabicLevel2QuizAllScreen extends StatefulWidget {
  const ArabicLevel2QuizAllScreen({super.key});

  @override
  State<ArabicLevel2QuizAllScreen> createState() => _ArabicLevel2QuizAllScreenState();
}

class _ArabicLevel2QuizAllScreenState extends State<ArabicLevel2QuizAllScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  int currentIndex = 0;
  int score = 0;
  bool showResult = false;
  String feedback = '';
  Color feedbackColor = Colors.transparent;
  String recognizedText = '';

  final List<Map<String, dynamic>> questions = [
    {
      "type": "speech",
      "text": "السيارة الحمراء توقفت عند الإشارة الحمراء احترامًا للقانون",
    },
    {
      "type": "choice",
      "sound": "نشاط",
      "question": "📢 ما الكلمة الصحيحة التي سمعتها؟",
      "options": ["نشاط", "نشاطا", "نشط"],
      "answer": "نشاط"
    },
    {
      "type": "letters",
      "word": "مطار",
      "question": "✍️ رتب الحروف لتكون الكلمة:"
    },
    {
      "type": "first_letter",
      "word": "مدرسة",
      "question": "❓ ما هو أول حرف في الكلمة مدرسة ؟",
      "options": ["م", "د", "ب"],
      "answer": "م"
    },
  ];

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.speak(text);
  }

  Future<void> evaluateSpeech(String expected) async {
    bool available = await speech.initialize();
    if (!available) return;

    speech.listen(
      localeId: 'ar_SA',
      partialResults: false,
      onResult: (val) {
        recognizedText = val.recognizedWords;
        bool isCorrect = recognizedText.trim() == expected.trim();
        setState(() {
          feedback = isCorrect ? "✅ أحسنت!" : "❌ حاول مرة أخرى";
          feedbackColor = isCorrect ? Colors.green : Colors.red;
          if (isCorrect) score++;
        });
      },
    );
  }

  void evaluateChoice(String selected, String correct) {
    final isCorrect = selected == correct;
    setState(() {
      feedback = isCorrect ? "✅ إجابة صحيحة" : "❌ إجابة خاطئة";
      feedbackColor = isCorrect ? Colors.green : Colors.red;
      if (isCorrect) score++;
    });
  }

  Widget buildLettersGame(String word) {
    List<String> letters = word.split('');
    letters.shuffle();
    List<String> selected = [];

    return StatefulBuilder(builder: (context, setLocalState) {
      return Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: letters.map((char) {
              return ElevatedButton(
                onPressed: () {
                  setLocalState(() {
                    selected.add(char);
                    letters.remove(char);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(char, style: const TextStyle(fontSize: 28)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            alignment: WrapAlignment.center,
            children: selected.map((c) => Chip(label: Text(c, style: const TextStyle(fontSize: 24)))).toList(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final attempt = selected.join();
              final isCorrect = attempt == word;
              setState(() {
                feedback = isCorrect ? "✅ ممتاز!" : "❌ خطأ";
                feedbackColor = isCorrect ? Colors.green : Colors.red;
                if (isCorrect) score++;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("تحقق", style: TextStyle(fontSize: 24)),
          ),
        ],
      );
    });
  }

  Widget buildCurrentQuestion() {
    final q = questions[currentIndex];

    switch (q["type"]) {
      case "speech":
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(q["text"], textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => speak(q["text"]),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("🔊 استمع للجملة", style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => evaluateSpeech(q["text"]),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("🎙️ سجّل نطقك", style: TextStyle(fontSize: 24)),
            ),
          ],
        );
      case "choice":
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(q["question"], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => speak(q["sound"]),
              icon: const Icon(Icons.volume_up),
              label: const Text("🔊 استمع للكلمة", style: TextStyle(fontSize: 22)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade200,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 16),
            ...q["options"].map<Widget>((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: () => evaluateChoice(option, q["answer"]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade100,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.orange),
                    ),
                  ),
                  child: Text(option, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                ),
              );
            }).toList()
          ],
        );
      case "letters":
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(q["question"], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            buildLettersGame(q["word"]),
          ],
        );
      case "first_letter":
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(q["question"], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...q["options"].map<Widget>((letter) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: () => evaluateChoice(letter, q["answer"]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade100,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.orange),
                    ),
                  ),
                  child: Text(letter, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                ),
              );
            }).toList()
          ],
        );
      default:
        return const Text("Unknown question type");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text("اختبار المستوى الثاني", style: TextStyle(fontSize: 26)),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: showResult
              ? Text("🎉 نتيجتك: $score من ${questions.length}",
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: buildCurrentQuestion()),
                    const SizedBox(height: 24),
                    Text(feedback, style: TextStyle(fontSize: 26, color: feedbackColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        if (currentIndex < questions.length - 1) {
                          setState(() {
                            currentIndex++;
                            feedback = '';
                            feedbackColor = Colors.transparent;
                          });
                        } else {
                          setState(() => showResult = true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      label: const Text("التالي", style: TextStyle(fontSize: 24)),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
