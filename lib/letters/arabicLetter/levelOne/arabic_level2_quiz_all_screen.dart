import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ArabicLevel2QuizAllScreen extends StatefulWidget {
  const ArabicLevel2QuizAllScreen({super.key});

  @override
  State<ArabicLevel2QuizAllScreen> createState() =>
      _ArabicLevel2QuizAllScreenState();
}

class _ArabicLevel2QuizAllScreenState extends State<ArabicLevel2QuizAllScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  int currentStep = 0;
  int score = 0;
  String feedback = '';
  Color feedbackColor = Colors.transparent;
  String recognizedText = '';
  String sentenceEvaluation = '';

  final List<Map<String, String>> sightWords = [
    {"correct": "قطار", "wrong": "قطر"},
    {"correct": "تفاحة", "wrong": "تفاحه"},
    {"correct": "مدرسة", "wrong": "مدرصة"},
  ];

  final List<String> assemblyWords = ["مطار", "كتاب", "حقيبة"];

  final List<String> sentenceQuiz = [
    "السيارة الحمراء توقفت عند الإشارة الحمراء احترامًا للقانون",
    "الولد المجتهد يذهب إلى المدرسة كل صباح بنشاط",
  ];

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ar-SA");
  }

  Future<void> speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  String normalize(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .trim();
  }

  int calculateAccuracy(String a, String b) {
    final m = a.length, n = b.length;
    if (m == 0 || n == 0) return 0;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (int i = 0; i <= m; i++) {
      for (int j = 0; j <= n; j++) {
        if (i == 0)
          dp[i][j] = j;
        else if (j == 0)
          dp[i][j] = i;
        else if (a[i - 1] == b[j - 1])
          dp[i][j] = dp[i - 1][j - 1];
        else
          dp[i][j] = 1 +
              [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]]
                  .reduce((x, y) => x < y ? x : y);
      }
    }

    final distance = dp[m][n];
    return ((1 - distance / n) * 100).clamp(0, 100).toInt();
  }

  Future<void> evaluateSentence(String expected) async {
    bool available = await speech.initialize();
    if (!available) return;

    setState(() {
      sentenceEvaluation = "🎤 جاري التسجيل...";
      feedbackColor = Colors.orange;
    });

    await speech.listen(
      localeId: 'ar_SA',
      partialResults: false,
      onResult: (val) {
        recognizedText = val.recognizedWords;
      },
    );

    for (int i = 5; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        sentenceEvaluation = "⏳ التسجيل ينتهي خلال: $i ثوانٍ";
      });
    }

    await speech.stop();

    final spoken = normalize(recognizedText);
    final expectedNorm = normalize(expected);
    final accuracy = calculateAccuracy(spoken, expectedNorm);

    setState(() {
      sentenceEvaluation = "📊 دقتك: $accuracy%\n🗣 ما قلته: $recognizedText";
      feedbackColor = accuracy >= 80 ? Colors.green : Colors.red;
    });

    if (accuracy >= 80) {
      score++;
      speak("أحسنت!");
    } else {
      speak("حاول مرة أخرى");
    }
  }

  Widget buildSightQuestion() {
    final data = sightWords[currentStep];
    final options = [data["correct"]!, data["wrong"]!]..shuffle();

    return Column(
      children: [
        const Text("🎧 استمع للكلمة واختر الصحيحة",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.volume_up),
          label: const Text("تشغيل", style: TextStyle(fontSize: 20)),
          onPressed: () => speak(data["correct"]!),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange, padding: const EdgeInsets.all(16)),
        ),
        const SizedBox(height: 24),
        ...options.map((word) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ElevatedButton(
              onPressed: () {
                final correct = word == data["correct"];
                setState(() {
                  feedback = correct ? "✅ صحيح!" : "❌ خطأ";
                  feedbackColor = correct ? Colors.green : Colors.red;
                });
                if (correct) score++;
                speak(feedback);
              },
              child: Text(word, style: const TextStyle(fontSize: 26)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade100,
                minimumSize: const Size(double.infinity, 60),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget buildAssemblyQuestion() {
    final word = assemblyWords[currentStep - sightWords.length];
    List<String> letters = word.split('')..shuffle();
    List<String> selected = [];

    return StatefulBuilder(builder: (context, setStateLocal) {
      return Column(
        children: [
          const Text("🧩 رتب الحروف لتكوين الكلمة",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.volume_up),
            label: const Text("تشغيل الكلمة", style: TextStyle(fontSize: 20)),
            onPressed: () => speak(word),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: letters.map((l) {
              return ElevatedButton(
                onPressed: () {
                  setStateLocal(() {
                    selected.add(l);
                    letters.remove(l);
                  });
                },
                child: Text(l, style: const TextStyle(fontSize: 28)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: selected
                .map((c) => Chip(label: Text(c, style: const TextStyle(fontSize: 26))))
                .toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            child: const Text("تحقق", style: TextStyle(fontSize: 20)),
            onPressed: () {
              final isCorrect = selected.join() == word;
              setState(() {
                feedback = isCorrect ? "✅ ممتاز" : "❌ حاول مرة أخرى";
                feedbackColor = isCorrect ? Colors.green : Colors.red;
              });
              if (isCorrect) score++;
              speak(feedback);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          )
        ],
      );
    });
  }

  Widget buildSentenceQuestion(int index) {
    final sentence = sentenceQuiz[index];
    return Column(
      children: [
        const Text("🗣 قم بقراءة الجملة التالية",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(
          sentence,
          style: const TextStyle(fontSize: 28, color: Colors.brown),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.volume_up),
          label: const Text("تشغيل الجملة", style: TextStyle(fontSize: 20)),
          onPressed: () => speak(sentence),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.mic),
          label: const Text("ابدأ التسجيل", style: TextStyle(fontSize: 20)),
          onPressed: () => evaluateSentence(sentence),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
        ),
        const SizedBox(height: 16),
        if (sentenceEvaluation.isNotEmpty)
          Text(sentenceEvaluation,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: feedbackColor)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSteps = sightWords.length + assemblyWords.length + sentenceQuiz.length;

    if (currentStep >= totalSteps) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("🎉 انتهيت من الكويز!",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text("نتيجتك: $score من $totalSteps",
                  style: const TextStyle(fontSize: 24, color: Colors.brown)),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.replay),
                label: const Text("إعادة", style: TextStyle(fontSize: 20)),
                onPressed: () {
                  setState(() {
                    currentStep = 0;
                    score = 0;
                    feedback = '';
                    sentenceEvaluation = '';
                  });
                },
              ),
            ],
          ),
        ),
      );
    }

    Widget content;
    if (currentStep < sightWords.length) {
      content = buildSightQuestion();
    } else if (currentStep < sightWords.length + assemblyWords.length) {
      content = buildAssemblyQuestion();
    } else {
      final index = currentStep - sightWords.length - assemblyWords.length;
      content = buildSentenceQuestion(index);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("الكويز الشامل - المستوى 2"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            content,
            const SizedBox(height: 20),
            if (feedback.isNotEmpty)
              Text(feedback,
                  style: TextStyle(fontSize: 24, color: feedbackColor)),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text("التالي", style: TextStyle(fontSize: 22)),
              onPressed: () {
                setState(() {
                  currentStep++;
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
    );
  }
}
