import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:confetti/confetti.dart';

class KaraokeReadingGame extends StatefulWidget {
  const KaraokeReadingGame({super.key});

  @override
  State<KaraokeReadingGame> createState() => _KaraokeReadingGameState();
}

class _KaraokeReadingGameState extends State<KaraokeReadingGame> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  final ConfettiController confettiController = ConfettiController(duration: const Duration(seconds: 2));

  int _currentWordIndex = -1;
  int _currentSentenceIndex = 0;
  String recognizedText = '';
  double accuracy = 0;
  Color feedbackColor = Colors.transparent;

  final List<List<String>> sentences = [
    ["The", "sun", "is", "bright."],
    ["I", "have", "a", "cat."],
    ["She", "likes", "to", "read", "books."],
    ["We", "are", "going", "to", "the", "park."],
    ["He", "plays", "soccer", "after", "school."],
    ["Look", "at", "that", "big", "elephant!"],
    ["Can", "you", "help", "me", "please?"],
    ["This", "is", "my", "favorite", "color."],
    ["They", "are", "eating", "ice", "cream."],
    ["The", "dog", "is", "under", "the", "table."],
  ];

  List<String> get currentWords => sentences[_currentSentenceIndex];
  String get fullSentence => currentWords.join(" ");

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.5);
    flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _speakWord(String word) async {
    await flutterTts.speak(word);
  }

  Future<void> _playSentence() async {
    for (int i = 0; i < currentWords.length; i++) {
      setState(() => _currentWordIndex = i);
      await _speakWord(currentWords[i]);
      await Future.delayed(const Duration(milliseconds: 500));
    }
    setState(() => _currentWordIndex = -1);
  }

  void _nextSentence() {
    setState(() {
      _currentSentenceIndex = (_currentSentenceIndex + 1) % sentences.length;
      _currentWordIndex = -1;
      recognizedText = '';
      accuracy = 0;
      feedbackColor = Colors.transparent;
    });
  }

  void _startRecording() async {
    bool available = await speech.initialize();
    if (!available) return;

    setState(() {
      recognizedText = '';
      accuracy = 0;
      feedbackColor = Colors.transparent;
    });

    speech.listen(
      localeId: "en_US",
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
      onResult: (val) {
        setState(() {
          recognizedText = val.recognizedWords;
        });
        _evaluatePronunciation();
      },
    );
  }

  void _evaluatePronunciation() {
    String expected = fullSentence.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
    String spoken = recognizedText.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();

    int distance = _levenshtein(expected, spoken);
    int maxLength = expected.length > 0 ? expected.length : 1;

    double score = ((1 - distance / maxLength) * 100).clamp(0, 100);

    setState(() {
      accuracy = score;
      feedbackColor = score >= 80 ? Colors.green : Colors.red;
      if (score >= 80) {
        confettiController.play();
        flutterTts.speak("Excellent! 🎉");
      } else {
        flutterTts.speak("Try again!");
      }
    });
  }

  int _levenshtein(String s, String t) {
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

  int getStars(double score) {
    if (score >= 90) return 3;
    if (score >= 80) return 2;
    if (score >= 60) return 1;
    return 0;
  }

  @override
  void dispose() {
    flutterTts.stop();
    speech.stop();
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int stars = getStars(accuracy);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text("🎙 Karaoke Reading"),
        backgroundColor: const Color(0xFFFF8B47),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            blastDirection: pi / 2,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            maxBlastForce: 15,
            minBlastForce: 5,
            gravity: 0.3,
            shouldLoop: false,
            colors: const [Colors.green, Colors.orange, Colors.pink],
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(2, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Read the sentence word by word aloud!",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: List.generate(currentWords.length, (i) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: i == _currentWordIndex ? Colors.orangeAccent : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFF8B47), width: 2),
                        ),
                        child: Text(
                          currentWords[i],
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _playSentence,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Play the sentence"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA726),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _startRecording,
                    icon: const Icon(Icons.mic),
                    label: const Text("Record your reading"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC80),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("You said: $recognizedText", style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text(
                    "Score: ${accuracy.toStringAsFixed(1)}%",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: feedbackColor),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Icon(
                        i < stars ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: accuracy >= 80 ? _nextSentence : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Next Sentence"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accuracy >= 80 ? const Color(0xFFFFD699) : Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
