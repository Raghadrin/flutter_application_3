import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ArabicLevel3Screen extends StatefulWidget {
  final String title;
  final String storyText;
  final List<String> questions;
  final List<String> correctAnswers;

  const ArabicLevel3Screen({
    super.key,
    required this.title,
    required this.storyText,
    required this.questions,
    required this.correctAnswers,
  });

  @override
  State<ArabicLevel3Screen> createState() => _ArabicLevel3ScreenState();
}

class _ArabicLevel3ScreenState extends State<ArabicLevel3Screen> {
  late FlutterTts flutterTts;
  late stt.SpeechToText speech;

  int currentQuestion = 0;
  int correctCount = 0;
  String selectedAnswer = '';
  bool showFeedback = false;
  bool isCorrect = false;
  bool showSummary = false;
  double voiceScore = 0;
  String voiceFeedback = '';
  Color feedbackColor = Colors.transparent;

  final List<String> dummyOptions = [
    "البحر", "الأصدقاء", "الطعام", "الملعب", "الشجرة", "النوم"
  ];

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("ar-SA");
    flutterTts.setSpeechRate(0.4);
    speech = stt.SpeechToText();

    Future.delayed(const Duration(milliseconds: 500), () {
      speak("مرحبًا بك! لنبدأ القصة معًا");
    });
  }

  Future<void> speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  String normalize(String input) {
    return input
        .replaceAll(RegExp(r'[^\u0621-\u064A\u064B-\u0652\s]'), '')
        .replaceAll('  ', ' ')
        .trim();
  }

  double similarity(String a, String b) {
    int match = 0;
    int minLen = a.length < b.length ? a.length : b.length;
    for (int i = 0; i < minLen; i++) {
      if (a[i] == b[i]) match++;
    }
    return (match / b.length * 100);
  }

  Future<void> evaluateStorySpeech() async {
    if (speech.isListening) await speech.stop();

    bool available = await speech.initialize();
    if (!available) return;

    setState(() {
      voiceFeedback = "🎙️ استمع الآن...";
      feedbackColor = Colors.blueGrey;
    });

    speech.listen(
      localeId: 'ar_SA',
      listenMode: stt.ListenMode.dictation,
      listenFor: const Duration(seconds: 90),
      pauseFor: const Duration(seconds: 30),
      partialResults: false,
      onResult: (val) {
        final expected = normalize(widget.storyText);
        final spoken = normalize(val.recognizedWords);

        List<String> expectedWords = expected.split(' ');
        List<String> spokenWords = spoken.split(' ');

        int matchCount = 0;
        for (int i = 0; i < expectedWords.length; i++) {
          if (i < spokenWords.length) {
            double score = similarity(spokenWords[i], expectedWords[i]);
            if (score >= 80 || (expectedWords[i].length <= 3 && score >= 60)) {
              matchCount++;
            }
          }
        }

        double finalScore =
            (matchCount / expectedWords.length * 100).clamp(0, 100);

        String feedback;
        Color color;
        if (finalScore >= 80) {
          feedback = "✅ ممتاز جدًا!\nتطابق بنسبة: ${finalScore.toStringAsFixed(1)}٪";
          color = Colors.green;
        } else if (finalScore >= 70) {
          feedback = "✨ جيد، تابع المحاولة\n${finalScore.toStringAsFixed(1)}٪";
          color = Colors.orange;
        } else {
          feedback = "❌ حاول من جديد\n${finalScore.toStringAsFixed(1)}٪";
          color = Colors.red;
        }

        setState(() {
          voiceScore = finalScore;
          feedbackColor = color;
          voiceFeedback = feedback;
        });
      },
    );
  }

  List<String> generateOptions(String correct) {
    final options = <String>{correct};
    while (options.length < 4) {
      options.add(dummyOptions[(options.length * 2 + correct.length) % dummyOptions.length]);
    }
    return options.toList()..shuffle();
  }

  Widget buildQuestionTab() {
    if (showSummary) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🌟 ملخص التقييم", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                return Icon(i < correctCount ? Icons.star : Icons.star_border,
                    color: Colors.orange, size: 40);
              }),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, size: 30),
              label: const Text("إعادة المحاولة", style: TextStyle(fontSize: 24)),
              onPressed: () {
                setState(() {
                  currentQuestion = 0;
                  correctCount = 0;
                  selectedAnswer = '';
                  showFeedback = false;
                  showSummary = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.home, size: 28),
              label: const Text("العودة إلى القصص", style: TextStyle(fontSize: 22)),
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ],
        ),
      );
    }

    final question = widget.questions[currentQuestion];
    final correct = widget.correctAnswers[currentQuestion];
    final options = generateOptions(correct);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("🧠 $question", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          ...options.map((answer) {
            final isSelected = selectedAnswer == answer;
            final isAnswerCorrect = answer == correct;

            return GestureDetector(
              onTap: () async {
                await flutterTts.stop();
                setState(() {
                  selectedAnswer = answer;
                  isCorrect = isAnswerCorrect;
                  showFeedback = true;
                  if (isAnswerCorrect) correctCount++;
                });

                await speak(isAnswerCorrect ? "أحسنت!" : "حاول مرة أخرى");

                if (isAnswerCorrect) {
                  Future.delayed(const Duration(seconds: 2), () {
                    if (currentQuestion < widget.questions.length - 1) {
                      setState(() {
                        currentQuestion++;
                        selectedAnswer = '';
                        showFeedback = false;
                      });
                    } else {
                      setState(() => showSummary = true);
                      speak("أحسنت، لقد أنهيت القصة بنجاح!");
                    }
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 14),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: Text(answer, style: const TextStyle(fontSize: 26)),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          if (showFeedback)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: feedbackColor.withOpacity(0.1),
                border: Border.all(color: feedbackColor),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                isCorrect ? "✅ إجابة صحيحة" : "❌ إجابة خاطئة",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: feedbackColor),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildStoryTab() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          border: Border.all(color: Colors.orange.shade200, width: 2),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "📖 لنقرأ القصة معًا!",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.brown.shade200),
              ),
              child: Text(
                widget.storyText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.brown),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.volume_up, size: 36),
              label: const Text("استمع للجملة", style: TextStyle(fontSize: 26)),
              onPressed: () => speak(widget.storyText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.mic, size: 30),
              label: const Text("قيّم نطقك", style: TextStyle(fontSize: 26)),
              onPressed: evaluateStorySpeech,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
            const SizedBox(height: 20),
            if (voiceFeedback.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: feedbackColor, width: 2),
                  color: feedbackColor.withOpacity(0.1),
                ),
                child: Text(
                  voiceFeedback,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: feedbackColor),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: const Color(0xFFFDF7E4),
          appBar: AppBar(
            backgroundColor: Colors.orange,
            title: Text(widget.title, style: const TextStyle(fontSize: 28)),
            bottom: const TabBar(
              labelStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: "الجملة"),
                Tab(text: "الأسئلة"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              buildStoryTab(),
              buildQuestionTab(),
            ],
          ),
        ),
      ),
    );
  }
}
