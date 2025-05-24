import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ArabicLetterQuizScreen extends StatefulWidget {
  const ArabicLetterQuizScreen({super.key});

  @override
  State<ArabicLetterQuizScreen> createState() => _ArabicLetterQuizScreenState();
}

class _ArabicLetterQuizScreenState extends State<ArabicLetterQuizScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int currentIndex = 0;
  int correctAnswers = 0;
  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;
  IconData? feedbackIcon;

  final List<Map<String, dynamic>> questions = [
    {"type": "position", "word": "بنت", "letter": "ب", "correctPosition": "بداية"},
    {"type": "position", "word": "كتاب", "letter": "ت", "correctPosition": "وسط"},
    {"type": "position", "word": "قلب", "letter": "ب", "correctPosition": "نهاية"},
    {"type": "letterChoice", "prompt": "اختر حرف الشين", "correctLetter": "ش", "options": ["س", "ش", "ص", "ث"]},
    {"type": "letterChoice", "prompt": "اختر حرف العين", "correctLetter": "ع", "options": ["غ", "ق", "ع"]},
    {"type": "letterChoice", "prompt": "اختر حرف الذال", "correctLetter": "ذ", "options": ["ز", "د", "ذ"]},
    {"type": "missingLetter", "incompleteWord": "م رسة", "correctLetter": "د", "options": ["ب", "ر", "د", "س"]},
    {"type": "missingLetter", "incompleteWord": " طار ", "correctLetter": "ق", "options": ["ف", "ك", "ق", "غ"]},
    {"type": "missingLetter", "incompleteWord": "حقي ة", "correctLetter": "ب", "options": ["ب", "د", "ذ", "ز"]},
    {"type": "audioMatch", "audioLetter": "ت", "correctLetter": "ت", "options": ["ت", "د", "س"]},
    {"type": "audioMatch", "audioLetter": "ع", "correctLetter": "ع", "options": ["غ", "ق", "ع"]},
    {"type": "audioMatch", "audioLetter": "ذ", "correctLetter": "ذ", "options": ["ز", "د", "ذ"]},
    {"type": "wordWithLetter", "targetLetter": "ر", "correctWord": "قمر", "options": ["شمس", "قمر", "بيت"]},
    {"type": "wordWithLetter", "targetLetter": "ف", "correctWord": "فيل", "options": ["فيل", "نمر", "كلب"]},
    {"type": "wordWithLetter", "targetLetter": "ك", "correctWord": "كتاب", "options": ["قمر", "بيت", "كتاب"]},
  ];

  @override
  void initState() {
    super.initState();
    _speakQuestion(questions[currentIndex]);
  }

  Future<void> _speakQuestion(Map<String, dynamic> question) async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setSpeechRate(0.4);
    String text = "";
    switch (question["type"]) {
      case "position":
        text = "أين يقع الحرف ${question["letter"]} في كلمة ${question["word"]}";
        break;
      case "letterChoice":
        text = question["prompt"];
        break;
      case "missingLetter":
        text = "ما هو الحرف الناقص في كلمة ${question["incompleteWord"]}";
        break;
      case "audioMatch":
        text = "استمع جيدًا ثم اختر الحرف الصحيح";
        break;
      case "wordWithLetter":
        text = "اختر الكلمة التي تحتوي على الحرف ${question["targetLetter"]}";
        break;
    }
    await flutterTts.speak(text);
  }

  void checkAnswer(String selected) {
    final q = questions[currentIndex];
    bool isCorrect = false;

    if (q["type"] == "position") {
      isCorrect = selected == q["correctPosition"];
    } else if (["letterChoice", "audioMatch", "missingLetter"].contains(q["type"])) {
      isCorrect = selected == q["correctLetter"];
    } else if (q["type"] == "wordWithLetter") {
      isCorrect = selected == q["correctWord"];
    }

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

  Future<void> _playSound(String letter) async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(letter);
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= questions.length) {
      int scorePercent = ((correctAnswers / questions.length) * 100).round();
      String message;
      Color color;

      if (scorePercent >= 90) {
        message = "🌟 ممتاز جدًا!";
        color = Colors.green;
      } else if (scorePercent >= 70) {
        message = "👏 عمل رائع!";
        color = Colors.orange;
      } else {
        message = "😅 حاول مرة أخرى!";
        color = Colors.red;
      }

      return Scaffold(
        backgroundColor: Colors.orange[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("النتيجة النهائية", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text("$scorePercent%", style: const TextStyle(fontSize: 60, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(message, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("التالي ⏭️", style: TextStyle(fontSize: 24, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final q = questions[currentIndex];
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('كويز الحروف', style: TextStyle(fontSize: 26)),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuestionWidget(q),
              if (feedbackMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(feedbackIcon, color: feedbackColor, size: 32),
                      const SizedBox(width: 10),
                      Text(feedbackMessage,
                          style: TextStyle(fontSize: 24, color: feedbackColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionWidget(Map<String, dynamic> q) {
    switch (q["type"]) {
      case "position":
        return _buildChoiceQuestion("أين يقع الحرف '${q['letter']}' في الكلمة '${q['word']}'؟", ["بداية", "وسط", "نهاية"]);
      case "letterChoice":
        return _buildChoiceQuestion(q["prompt"], q["options"]);
      case "missingLetter":
        return _buildChoiceQuestion("ما هو الحرف الناقص في: ${q["incompleteWord"]}", q["options"]);
      case "audioMatch":
        return Column(
          children: [
            const Text("🎧 استمع واختر الحرف", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _playSound(q["audioLetter"]),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent, padding: const EdgeInsets.all(16)),
              child: const Icon(Icons.volume_up, size: 40),
            ),
            const SizedBox(height: 20),
            _answerButtons(q["options"]),
          ],
        );
      case "wordWithLetter":
        return _buildChoiceQuestion("اختر الكلمة التي تحتوي على الحرف '${q["targetLetter"]}'", q["options"]);
      default:
        return const Text("سؤال غير معروف");
    }
  }

  Widget _buildChoiceQuestion(String question, List options) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange, width: 3),
          ),
          child: Column(
            children: [
              Text("سؤال ${currentIndex + 1}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              const SizedBox(height: 10),
              Text(question, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24)),
            ],
          ),
        ),
        _answerButtons(options),
      ],
    );
  }

  Widget _answerButtons(List options) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: options.map<Widget>((opt) {
        return ElevatedButton(
          onPressed: () => checkAnswer(opt),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            minimumSize: const Size(140, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(opt, style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
        );
      }).toList(),
    );
  }
}
