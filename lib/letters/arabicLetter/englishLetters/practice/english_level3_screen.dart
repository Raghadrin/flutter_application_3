import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class EnglishLevel3Screen extends StatefulWidget {
  final String title;
  final String storyText;
  final List<String> questions;
  final List<String> correctAnswers;

  const EnglishLevel3Screen({
    super.key,
    required this.title,
    required this.storyText,
    required this.questions,
    required this.correctAnswers,
  });

  @override
  State<EnglishLevel3Screen> createState() => _EnglishLevel3ScreenState();
}

class _EnglishLevel3ScreenState extends State<EnglishLevel3Screen> {
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
    "the beach", "friends", "food", "the park", "clouds", "playing"
  ];

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.4);
    speech = stt.SpeechToText();
    Future.delayed(const Duration(milliseconds: 600), () {
      speak("Welcome! Let's begin the story.");
    });
  }

  Future<void> speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  String normalize(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^a-z\s]'), '').trim();
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
      voiceFeedback = "🎙️ Listening...";
      feedbackColor = Colors.blueGrey;
    });

    speech.listen(
      localeId: 'en_US',
      listenMode: stt.ListenMode.dictation,
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 20),
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

        double finalScore = (matchCount / expectedWords.length * 100).clamp(0, 100);

        String feedback;
        Color color;
        if (finalScore >= 80) {
          feedback = "✅ Excellent!\nScore: ${finalScore.toStringAsFixed(1)}%";
          color = Colors.green;
        } else if (finalScore >= 70) {
          feedback = "✨ Good effort\nScore: ${finalScore.toStringAsFixed(1)}%";
          color = Colors.orange;
        } else {
          feedback = "❌ Try again\nScore: ${finalScore.toStringAsFixed(1)}%";
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

  Widget buildStoryTab() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          border: Border.all(color: Colors.orange.shade200, width: 1.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "📖 Let's read the story!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.brown.shade200),
              ),
              child: Text(
                widget.storyText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.volume_up, size: 22),
              label: const Text("Listen", style: TextStyle(fontSize: 18)),
              onPressed: () => speak(widget.storyText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.mic, size: 20),
              label: const Text("Check your pronunciation", style: TextStyle(fontSize: 18)),
              onPressed: evaluateStorySpeech,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            if (voiceFeedback.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: feedbackColor, width: 1.5),
                  color: feedbackColor.withOpacity(0.1),
                ),
                child: Text(
                  voiceFeedback,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: feedbackColor),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildQuestionTab() {
    if (showSummary) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🌟 Your Summary", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                return Icon(i < correctCount ? Icons.star : Icons.star_border, color: Colors.orange, size: 28);
              }),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Try Again", style: TextStyle(fontSize: 18)),
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
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text("Back to stories", style: TextStyle(fontSize: 18)),
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("❓ $question", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
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

                await speak(isAnswerCorrect ? "Great job!" : "Try again");

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
                      speak("Well done! You've completed the story.");
                    }
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.orange, width: 1.5),
                ),
                child: Text(answer, style: const TextStyle(fontSize: 18)),
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          if (showFeedback)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: feedbackColor.withOpacity(0.1),
                border: Border.all(color: feedbackColor),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                isCorrect ? "✅ Correct Answer" : "❌ Wrong Answer",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: feedbackColor),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: const Color(0xFFFDF7E4),
          appBar: AppBar(
            backgroundColor: Colors.orange,
            toolbarHeight: 56,
            title: Text(widget.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
            bottom: const TabBar(
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              indicatorWeight: 3,
              tabs: [
                Tab(text: "Story"),
                Tab(text: "Questions"),
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
