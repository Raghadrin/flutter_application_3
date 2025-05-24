import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ArabicQuizWithSentenceEvaluation extends StatefulWidget {
  const ArabicQuizWithSentenceEvaluation({super.key});

  @override
  State<ArabicQuizWithSentenceEvaluation> createState() =>
      _ArabicQuizWithSentenceEvaluationState();
}

class _ArabicQuizWithSentenceEvaluationState
    extends State<ArabicQuizWithSentenceEvaluation> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  int currentQuestionIndex = 0;
  bool answered = false;
  String feedback = '';
  Color feedbackColor = Colors.transparent;
  String recognizedText = '';
  String sentenceEvaluation = '';
  int totalCorrect = 0;

  final List<Map<String, dynamic>> quizData = [
    {
      "sentence": "الولد يرسم صورة جميلة",
      "question": "ما هي أول كلمة في الجملة؟",
      "options": ["الولد", "يرسم", "صورة"],
      "answer": "الولد"
    },
    {
      "sentence": "السماء زرقاء وصافية اليوم",
      "question": "ما هي الكلمة التي تدل على اللون؟",
      "options": ["زرقاء", "اليوم", "وصافية"],
      "answer": "زرقاء"
    },
    {
      "sentence": "أحضرت فاطمة حقيبتها إلى المدرسة",
      "question": "من أحضر الحقيبة؟",
      "options": ["فاطمة", "حقيبة", "مدرسة"],
      "answer": "فاطمة"
    },
    {
      "sentence": "جلس القط على الكرسي",
      "question": "أين جلس القط؟",
      "options": ["على الكرسي", "في الغرفة", "تحت الطاولة"],
      "answer": "على الكرسي"
    }
  ];

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ar-SA");
    flutterTts.setSpeechRate(0.4);
  }

  Future<void> speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  void checkAnswer(String selected, String correct) {
    final isCorrect = normalize(selected) == normalize(correct);
    if (isCorrect) totalCorrect++;
    setState(() {
      answered = true;
      feedback = isCorrect ? "أحسنت! ✅" : "إجابة خاطئة ❌";
      feedbackColor = isCorrect ? Colors.green : Colors.red;
    });
    speak(feedback);
  }

 
String normalize(String text) {
  return text
      .trim()
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'[^\u0600-\u06FF\s]'), ''); // إزالة الرموز
}


  Future<void> evaluateSpokenSentence(String expectedSentence) async {
  bool available = await speech.initialize();
  if (!available) {
    setState(() {
      sentenceEvaluation = "❌ الميكروفون غير متاح";
      feedbackColor = Colors.red;
    });
    return;
  }

  setState(() {
    recognizedText = '';
    sentenceEvaluation = "🎙 جاري الاستماع لمدة 5 ثوانٍ...";
    feedbackColor = Colors.orange;
  });

  await speech.listen(
    localeId: 'ar_SA',
    partialResults: false,
    onResult: (val) {
      recognizedText = val.recognizedWords;
      print("👂 تم التعرف على: $recognizedText");
    },
  );

  // ⏳ انتظر 5 ثوانٍ
  await Future.delayed(const Duration(seconds: 10));
  await speech.stop();

  final expected = normalize(expectedSentence);
  final spoken = normalize(recognizedText);

  int score = calculateAccuracy(spoken, expected);

  setState(() {
    sentenceEvaluation = "📊 دقتك: $score%\n🗣 ما قلته: $recognizedText";
    feedbackColor = score >= 80 ? Colors.green : Colors.red;
  });

  if (score >= 80) {
    speak("قراءة ممتازة!");
  } else {
    speak("حاول مرة أخرى");
  }
}

 int calculateAccuracy(String spoken, String expected) {
  spoken = spoken.trim();
  expected = expected.trim();

  int m = spoken.length;
  int n = expected.length;

  if (m == 0 || n == 0) return 0;

  List<List<int>> dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

  for (int i = 0; i <= m; i++) {
    for (int j = 0; j <= n; j++) {
      if (i == 0) {
        dp[i][j] = j;
      } else if (j == 0) {
        dp[i][j] = i;
      } else if (spoken[i - 1] == expected[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1];
      } else {
        dp[i][j] = 1 + [
          dp[i - 1][j],     // حذف
          dp[i][j - 1],     // إدراج
          dp[i - 1][j - 1]  // استبدال
        ].reduce((a, b) => a < b ? a : b);
      }
    }
  }

  int distance = dp[m][n];
  double similarity = (1 - distance / n);
  return (similarity * 100).clamp(0, 100).toInt();
}

  @override
  Widget build(BuildContext context) {
    if (currentQuestionIndex >= quizData.length) {
      return Scaffold(
        backgroundColor: Colors.orange.shade50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("🎉 تم الانتهاء من الكويز!",
                  style: TextStyle(fontSize: 28, color: Colors.orange)),
              const SizedBox(height: 20),
              Text("نتيجتك: $totalCorrect من ${quizData.length}",
                  style: const TextStyle(fontSize: 24, color: Colors.brown)),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("إعادة المحاولة",
                    style: TextStyle(fontSize: 20)),
                onPressed: () {
                  setState(() {
                    currentQuestionIndex = 0;
                    answered = false;
                    feedback = '';
                    totalCorrect = 0;
                    sentenceEvaluation = '';
                  });
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              )
            ],
          ),
        ),
      );
    }

    final current = quizData[currentQuestionIndex];
    final sentence = current["sentence"];
    final question = current["question"];
    final options = current["options"] as List<String>;
    final correctAnswer = current["answer"];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.orange.shade50,
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: const Text("كويز الجمل", style: TextStyle(fontSize: 24)),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("📘 $sentence",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.volume_up),
                  label: const Text("تشغيل الجملة"),
                  onPressed: () => speak(sentence),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14)),
                ),
                const SizedBox(height: 24),
                Text(question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  alignment: WrapAlignment.center,
                  children: options.map((option) {
                    return ElevatedButton(
                      onPressed: () => checkAnswer(option, correctAnswer),
                      child:
                          Text(option, style: const TextStyle(fontSize: 22)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade100,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                if (feedback.isNotEmpty)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: feedbackColor.withOpacity(0.1),
                      border: Border.all(color: feedbackColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(feedback,
                        style: TextStyle(fontSize: 22, color: feedbackColor)),
                  ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.mic),
                  label: const Text("سجّل الجملة",
                      style: TextStyle(fontSize: 20)),
                  onPressed: () => evaluateSpokenSentence(sentence),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14)),
                ),
                const SizedBox(height: 12),
                if (sentenceEvaluation.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: feedbackColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      sentenceEvaluation,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, color: feedbackColor),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("السؤال التالي",
                      style: TextStyle(fontSize: 20)),
                  onPressed: () {
                    setState(() {
                      currentQuestionIndex++;
                      answered = false;
                      feedback = '';
                      sentenceEvaluation = '';
                      recognizedText = '';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
