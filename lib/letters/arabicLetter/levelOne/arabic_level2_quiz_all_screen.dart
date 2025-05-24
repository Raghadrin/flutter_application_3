
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ArabicLevel2WordQuizScreen extends StatefulWidget {
  const ArabicLevel2WordQuizScreen({super.key});

  @override
  State<ArabicLevel2WordQuizScreen> createState() => _ArabicLevel2WordQuizScreenState();
}

class _ArabicLevel2WordQuizScreenState extends State<ArabicLevel2WordQuizScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int currentIndex = 0;
  int correctAnswers = 0;
  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;
  IconData? feedbackIcon;

  final List<Map<String, dynamic>> questions = [
    {
      "type": "sentenceChoice",
      "question": "اختر الجملة التي تحتوي على كلمة تفاحة",
      "correct": "أكلت ليلى تفاحة حمراء.",
      "options": [
        "ذهب أحمد إلى السوق.",
        "أكلت ليلى تفاحة حمراء.",
        "لعب سامي في الحديقة."
      ]
    },
    {
      "type": "synonymChoice",
      "question": "ما مرادف كلمة 'سعيد'؟",
      "correct": "فرحان",
      "options": ["فرحان", "جائع", "غاضب"]
    },
    {
      "type": "oppositeChoice",
      "question": "ما عكس كلمة 'كبير'؟",
      "correct": "صغير",
      "options": ["طويل", "صغير", "قديم"]
    },
    {
      "type": "categoryChoice",
      "question": "أي كلمة تنتمي إلى 'الفواكه'؟",
      "correct": "تفاح",
      "options": ["تفاح", "قلم", "باب"]
    },
    {
      "type": "audioWord",
      "sound": "تفاحة",
      "correct": "تفاحة",
      "options": ["تفاحة", "موزة", "برتقالة"],
    },
    {
      "type": "missingWord",
      "sentence": "أكل سامي       حمراء.",
      "correct": "تفاحة",
      "options": ["موزة", "تفاحة", "تفاح"],
    },
    {
      "type": "wordWithLetter",
      "letter": "س",
      "correct": "سمكة",
      "options": ["تفاحة", "سمكة", "قلم"],
    },
  ];

  @override
  void initState() {
    super.initState();
    _speakQuestion();
  }

  Future<void> _speakQuestion() async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setSpeechRate(0.4);
    final q = questions[currentIndex];
    String text = "";
    switch (q['type']) {
      case "sentenceChoice":
      case "synonymChoice":
      case "oppositeChoice":
      case "categoryChoice":
        text = q['question'];
        break;
      case "audioWord":
        text = "استمع ثم اختر الكلمة الصحيحة";
        break;
      case "missingWord":
        text = "ما الكلمة الناقصة في الجملة: ${q['sentence']}";
        break;
      case "wordWithLetter":
        text = "اختر الكلمة التي تحتوي على الحرف ${q['letter']}";
        break;
    }
    await flutterTts.speak(text);
  }

  void checkAnswer(String selected) {
    final q = questions[currentIndex];
    bool isCorrect = selected == q['correct'];

    setState(() {
      if (isCorrect) {
        correctAnswers++;
        feedbackMessage = "🎉 إجابة صحيحة!";
        feedbackColor = Colors.green;
        feedbackIcon = Icons.check_circle;
        flutterTts.speak("إجابة صحيحة");
      } else {
        feedbackMessage = "❌ إجابة خاطئة";
        feedbackColor = Colors.red;
        feedbackIcon = Icons.cancel;
        flutterTts.speak("إجابة خاطئة");
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        currentIndex++;
        feedbackMessage = '';
        feedbackColor = Colors.transparent;
        feedbackIcon = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (feedbackMessage == '' && currentIndex < questions.length) {
        _speakQuestion();
      }
    });

    if (currentIndex >= questions.length) {
      int scorePercent = ((correctAnswers / questions.length) * 100).round();
      String finalMessage;
      Color msgColor;

      if (scorePercent >= 90) {
        finalMessage = "ممتاز جدًا 🎉";
        msgColor = Colors.green;
      } else if (scorePercent >= 70) {
        finalMessage = "عمل رائع 👏";
        msgColor = Colors.orange;
      } else {
        finalMessage = "أحسنت المحاولة 💪";
        msgColor = Colors.red;
      }

      return Scaffold(
        backgroundColor: Colors.orange[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("النتيجة النهائية", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text("$scorePercent%",
                  style: const TextStyle(fontSize: 50, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(finalMessage, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: msgColor)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("التالي ⏭️", style: TextStyle(fontSize: 24, color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    final q = questions[currentIndex];
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('كويز الكلمات - مستوى 2', style: TextStyle(fontSize: 26)),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: Column(
                  children: [
                    Text(
                      "السؤال ${currentIndex + 1} من ${questions.length}",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    ),
                    const SizedBox(height: 12),
                    if (q['type'] == 'missingWord')
                      Text(q['sentence'], style: const TextStyle(fontSize: 24))
                    else if (q['type'] == 'wordWithLetter')
                      Text("🔠 اختر كلمة تحتوي ${q['letter']}", style: const TextStyle(fontSize: 24))
                    else if (q['type'] == 'audioWord')
                      Column(
                        children: [
                          const Text("🎧 اضغط للاستماع", style: TextStyle(fontSize: 24)),
                          IconButton(
                            icon: const Icon(Icons.volume_up, size: 40),
                            onPressed: () => flutterTts.speak(q['sound']),
                          )
                        ],
                      )
                    else if (q.containsKey('question'))
                      Text(q['question'], style: const TextStyle(fontSize: 24)),
                    _readButton(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ...List<Widget>.from(
                q['options'].map((opt) {
                  if (opt is String) {
                    return _answerButton(opt);
                  } else if (opt is Map && opt.containsKey('label')) {
                    return _answerButton(opt['label']);
                  } else {
                    return const SizedBox();
                  }
                }),
              ),
              if (feedbackMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(feedbackIcon, color: feedbackColor, size: 32),
                      const SizedBox(width: 10),
                      Text(
                        feedbackMessage,
                        style: TextStyle(fontSize: 24, color: feedbackColor, fontWeight: FontWeight.bold),
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

  Widget _readButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ElevatedButton.icon(
        onPressed: _speakQuestion,
        icon: const Icon(Icons.volume_up),
        label: const Text("اقرأ السؤال", style: TextStyle(fontSize: 20)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _answerButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () => checkAnswer(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 4,
        ),
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
