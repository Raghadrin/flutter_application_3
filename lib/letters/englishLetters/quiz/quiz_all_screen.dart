import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:confetti/confetti.dart';

class QuizEScreen extends StatefulWidget {
  final String subject;

  const QuizEScreen({required this.subject, Key? key}) : super(key: key);

  @override
  _QuizEScreenState createState() => _QuizEScreenState();
}

class _QuizEScreenState extends State<QuizEScreen> {
  final List<Map<String, String>> quizData = [
    {
      "paragraph": "We visited the museum and saw old paintings and sculptures.",
      "target": "museum",
      "emoji": "🏛️"
    },
    {
      "paragraph": "My brother baked a chocolate cake all by himself.",
      "target": "cake",
      "emoji": "🎂"
    },
    {
      "paragraph": "She read her favorite story under a tree in the garden.",
      "target": "story",
      "emoji": "📖"
    },
  ];

  int currentIndex = 0;
  double score = 0;
  bool isListening = false;
  String spokenText = '';
  double wordScore = 0;
  double sentenceScore = 0;
  bool showNext = false;
  String? motivationalMessage;
  final ConfettiController confettiController = ConfettiController(duration: Duration(seconds: 2));

  final flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  final Duration maxTime = Duration(minutes: 2);
  Duration timeLeft = Duration(minutes: 2);
  Timer? timer;

  final List<String> messages = [
    "Excellent!",
    "Well done!",
    "Great pronunciation!",
    "Try again!"
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.5);
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft.inSeconds == 0) {
        timer.cancel();
        _showFinalScore();
      } else {
        setState(() {
          timeLeft -= const Duration(seconds: 1);
        });
      }
    });
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  Future<void> evaluate(String word, String sentence) async {
    bool available = await speech.initialize();
    if (!available) return;

    setState(() {
      spokenText = '';
      wordScore = 0;
      sentenceScore = 0;
      motivationalMessage = null;
      isListening = true;
      showNext = false;
    });

    speech.listen(
      onResult: (result) {
        spokenText = result.recognizedWords;

        if (word.isNotEmpty) {
          wordScore = calculateScore(word, spokenText);
        }
        if (sentence.isNotEmpty) {
          sentenceScore = calculateScore(sentence, spokenText);
        }

        if ((wordScore >= 80 || sentenceScore >= 80)) {
          score += 1;
          motivationalMessage = messages[Random().nextInt(messages.length - 1)];
          showNext = true;
          if (score == quizData.length) confettiController.play();
        } else {
          motivationalMessage = "Try again!";
        }

        setState(() => isListening = false);
        speech.stop();
      },
      localeId: "en_US",
      listenMode: stt.ListenMode.dictation,
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
    );
  }

  double calculateScore(String original, String spoken) {
    original = original.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');
    spoken = spoken.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');
    int distance = levenshtein(original, spoken);
    int maxLength = max(original.length, spoken.length);
    return ((1 - distance / maxLength) * 100).clamp(0, 100);
  }

  int levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<List<int>> matrix = List.generate(s.length + 1, (_) => List<int>.filled(t.length + 1, 0));
    for (int i = 0; i <= s.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= t.length; j++) matrix[0][j] = j;

    for (int i = 1; i <= s.length; i++) {
      for (int j = 1; j <= t.length; j++) {
        int cost = s[i - 1] == t[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost
        ].reduce(min);
      }
    }

    return matrix[s.length][t.length];
  }

  void _showFinalScore() {
    String emoji = score == quizData.length ? "🏆" : "✅";
    String message = score == quizData.length
        ? "Excellent!"
        : "Well done! Your score is ${score.toInt()} / ${quizData.length}";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("$emoji Final Score"),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("Return"),
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    speech.stop();
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = quizData[currentIndex];
    final paragraph = data["paragraph"]!;
    final target = data["target"]!;
    final emoji = data["emoji"]!;
    final parts = paragraph.split(target);

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text("Quiz - ${widget.subject}"),
        backgroundColor: Colors.orange,
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("⏱ ${formatTime(timeLeft)}"),
            ),
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 25,
            blastDirection: pi / 2,
            gravity: 0.3,
            shouldLoop: false,
            colors: const [Colors.orange, Colors.amber, Colors.deepOrangeAccent],
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Score: ${score.toInt()} / ${quizData.length}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 40)),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                        children: [
                          TextSpan(text: parts[0]),
                          TextSpan(
                            text: target,
                            style: const TextStyle(
                                backgroundColor: Colors.yellow, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: parts.length > 1 ? parts[1] : ''),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => flutterTts.speak(paragraph),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade100),
                    child: const Text("🔊 Listen to Sentence"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => flutterTts.speak(target),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade200),
                    child: const Text("🔊 Listen to Word"),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => evaluate(target, ""),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade100),
                        child: const Text("🎤 Record Word"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => evaluate("", paragraph),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade200),
                        child: const Text("📢 Record Sentence"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (spokenText.isNotEmpty)
                    Text("You said: \"$spokenText\"", textAlign: TextAlign.center),
                  if (wordScore > 0)
                    Text("Word Score: ${wordScore.toStringAsFixed(1)}%",
                        style: TextStyle(
                            color: wordScore >= 80 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold)),
                  if (sentenceScore > 0)
                    Text("Sentence Score: ${sentenceScore.toStringAsFixed(1)}%",
                        style: TextStyle(
                            color: sentenceScore >= 80 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold)),
                  if (motivationalMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        motivationalMessage!,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: motivationalMessage == "Try again!" ? Colors.red : Colors.green),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: (wordScore >= 80 || sentenceScore >= 80)
                        ? () {
                            if (currentIndex == quizData.length - 1) {
                              _showFinalScore();
                            } else {
                              setState(() {
                                currentIndex++;
                                spokenText = '';
                                wordScore = 0;
                                sentenceScore = 0;
                                motivationalMessage = null;
                                showNext = false;
                              });
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: (wordScore >= 80 || sentenceScore >= 80)
                            ? Colors.deepOrangeAccent.shade100
                            : Colors.grey.shade400),
                    child: Text(currentIndex == quizData.length - 1
                        ? "🏁 Finish Quiz"
                        : "➡️ Next"),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
